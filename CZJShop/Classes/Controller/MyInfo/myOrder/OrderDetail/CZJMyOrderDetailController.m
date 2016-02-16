//
//  CZJMyOrderDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyOrderDetailController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderForm.h"
#import "CZJOrderDetailCell.h"
#import "CZJDeliveryAddrCell.h"
#import "CZJOrderProductHeaderCell.h"
#import "CZJPromotionCell.h"
#import "CZJOrderProductFooterCell.h"
#import "CZJLeaveMessageCell.h"
#import "CZJGiftCell.h"

@interface CZJMyOrderDetailController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    CZJOrderDetailForm* orderDetailForm;
    NSString* stageStr;
    NSInteger stageNum;
    NSInteger orderType;
    UIColor* stageLabelColor;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeight;

//退换货 确认收货 查看物流
@property (weak, nonatomic) IBOutlet UIView *noReceiveView;

//取消订单
@property (weak, nonatomic) IBOutlet UIView *cancelOrderView;

//查看车检 付款 取消订单
@property (weak, nonatomic) IBOutlet UIView *carCheckView;

//去评价
@property (weak, nonatomic) IBOutlet UIView *goEvaluateView;

//付款 、查看车检结果
@property (weak, nonatomic) IBOutlet UIView *payCarCheckView;

//取消订单、付款
@property (weak, nonatomic) IBOutlet UIView *payCancleOrderView;

//查看车检结果
@property (weak, nonatomic) IBOutlet UIView *onlyCarCheckView;

//取消订单、查看车检结果
@property (weak, nonatomic) IBOutlet UIView *cancleCarCheckView;

//查看车检结果、查看施工进度
@property (weak, nonatomic) IBOutlet UIView *carCheckBuildingProgressView;

//查看车检结果、去评价
@property (weak, nonatomic) IBOutlet UIView *carCheckEvaluateView;

//联系车之健 取消退换货 提醒卖家同意
@property (weak, nonatomic) IBOutlet UIView *returnedDetailView;

@property (weak, nonatomic) IBOutlet UIView *buttomLineView;
@end

@implementation CZJMyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getOrderDetailFromServer];
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.separatorViewHeight.constant = 0.5;
    
    NSArray* nibArys = @[@"CZJOrderDetailCell",
                         @"CZJDeliveryAddrCell",
                         @"CZJOrderProductHeaderCell",
                         @"CZJPromotionCell",
                         @"CZJOrderProductFooterCell",
                         @"CZJLeaveMessageCell",
                         @"CZJGiftCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"订单详情";
}

- (void)getOrderDetailFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderDetail:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        orderDetailForm = [CZJOrderDetailForm objectWithKeyValues:dict];
        [self.myTableView reloadData];
        
        if (!orderDetailForm.paidFlag)
        {
            //type==0为商品，type==1为服务
            if (0 == [orderDetailForm.type integerValue])
            {//商品未付款 永远只有等待买家付款的状态，也就是status == 0
                stageStr = @"等待买家付款";
                stageNum = 0;
                orderType = 0;
                self.payCancleOrderView.hidden = NO;   //取消订单、付款
            }
            else if (1 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue]) {
                    stageStr = @"等待买家付款";
                    stageNum = 0;
                    orderType = 0;
                    self.payCancleOrderView.hidden = NO;   //取消订单、付款
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                    stageStr = @"等待门店施工(未付款)";
                    stageNum = 1;
                    orderType = 1;
                    self.carCheckView.hidden = NO; //取消订单、付款 、查看车检结果
                }
                else
                {
                    stageStr = @"门店正在施工(未付款)";
                    stageNum = 1;
                    orderType = 1;
                    self.payCarCheckView.hidden = NO;  //付款 、查看车检结果
                }
            }
        }
        
        else
        {
            if (orderDetailForm.evaluated)
            {
                stageLabelColor = UIColorFromRGB(0x48AB11);
                stageStr = @"订单已完成";
                stageNum = 3;
                orderType = 0;
                if ([orderDetailForm.type integerValue] == 0)
                {
                    self.buttomLineView.hidden = YES;
                }
                else
                {
                    self.onlyCarCheckView.hidden = NO;  //查看车检结果
                }
                
            }
            else
            {
                if ([orderDetailForm.status integerValue] != 4)
                {
                    stageNum = 1;
                    orderType = 0;
                    if (0 == [orderDetailForm.type integerValue])
                    {
                        if (1 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"卖家还没发货";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (2 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"卖家还没发货";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (3 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"等待买家收货";
                            self.noReceiveView.hidden = NO;  //退换货、查看物流、确认收货
                        }
                    }
                    else if (1 == [orderDetailForm.type integerValue])
                    {
                        if (0 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"等待到店施工";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (1 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"等待门店施工";
                            self.cancleCarCheckView.hidden = NO; //取消订单、查看车检结果
                        }
                        else if (2 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"门店正在施工";
                            self.carCheckBuildingProgressView.hidden = NO; //查看车检结果、查看施工进度
                        }
                        else if (3 == [orderDetailForm.status integerValue])
                        {
                            stageStr = @"门店正在施工";
                            self.carCheckBuildingProgressView.hidden = NO; //查看车检结果、查看施工进度
                        }
                    }
                }
                else
                {
                    stageStr = @"等待买家评价";
                    stageNum = 2;
                    orderType = 0;
                    if (0 == [orderDetailForm.type integerValue])
                    {
                        self.goEvaluateView.hidden = NO;            //去评价
                    }
                    else
                    {
                        self.carCheckEvaluateView.hidden = NO;      //查看车检结果、去评价
                    }
                }
            }
        }
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1 + (orderDetailForm.receiver.receiver == nil ? 0 : 1);
    }
    if (1 == section)
    {
        return  4 + orderDetailForm.items.count;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderDetailCell" forIndexPath:indexPath];
            cell.orderNoLabel.text = orderDetailForm.orderNo;
            cell.orderTimeLabel.text = orderDetailForm.createTime;
            [cell setOrderStateLayout:stageNum type:orderType];
            cell.stageLabel.text = stageStr;
            if (stageLabelColor)
            {
                cell.stageLabel.textColor = stageLabelColor;
            }
            cell.stageLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:stageStr WithFont:BOLDSYSTEMFONT(15)].width + 5;
            if (!orderDetailForm.paidFlag) {
                cell.leftTimeLabel.hidden = [orderDetailForm.timeOver isEqualToString:@""];
                cell.leftTimeLabel.text = [NSString stringWithFormat:@"剩余%@",orderDetailForm.timeOver];
            }
            else
            {
                cell.leftTimeLabel.hidden = YES;
            }
            return cell;
        }
        else if (1 == indexPath.row)
        {
            CZJDeliveryAddrCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrCell" forIndexPath:indexPath];
            cell.deliveryNameLabel.text = orderDetailForm.receiver.receiver;
            cell.deliveryAddrLabel.text = orderDetailForm.receiver.addr;
            cell.contactNumLabel.text = orderDetailForm.receiver.mobile;
            cell.defaultLabel.hidden = YES;
            cell.deliveryAddrLayoutLeading.constant = 41;
            cell.commitNextArrowImg.hidden = YES;
            return cell;
        }
    }
    
    if (1 == indexPath.section)
    {
        NSInteger itemCount = orderDetailForm.items.count;
        NSInteger giftCount = 0;            //礼品数量
        BOOL isHaveFullCut = [orderDetailForm.fullCutPrice integerValue] > 0.1;            //是否有满减
        BOOL isHaveCoupon = YES;             //是否有优惠券

        
        NSInteger fullcutCount = (isHaveFullCut || isHaveCoupon) ? 1 : 0;
        
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"storeHeaer"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"storeHeaer"];
            }
            
            [cell.imageView setImage:IMAGENAMED(@"commit_icon_shop")];
            cell.textLabel.text = orderDetailForm.storeName;
            return cell;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {
            CZJOrderGoodsForm* goodsForm = orderDetailForm.items[indexPath.row - 1];
            CZJOrderProductHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductHeaderCell" forIndexPath:indexPath];
            cell.setupView.hidden = YES;
            [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
            cell.goodsNameLabel.text = goodsForm.itemName;
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.1f",[goodsForm.currentPrice floatValue]];
            cell.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
            cell.goodsTypeLabel.text = goodsForm.itemSku;
            cell.setupView.hidden = !goodsForm.setupFlag;
            cell.goodsNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 68 -15 - 8 - 15;
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.1f",[goodsForm.itemCount floatValue] * [goodsForm.currentPrice integerValue]];
            cell.storeItemPid = goodsForm.storeItemPid;
            cell.selectedSetupStoreNameLabel.text = goodsForm.selectdSetupStoreName;
            cell.indexPath = indexPath;
            return cell;
        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= itemCount + fullcutCount)
        {
            CZJPromotionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJPromotionCell" forIndexPath:indexPath];
            cell.nameOneLabel.text = @"优惠券:";
            cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%.1f", [orderDetailForm.couponPrice floatValue]];
            
            cell.nameTwoLabel.hidden = !isHaveFullCut;
            cell.nameTwoNumLabel.hidden = !isHaveFullCut;
            cell.nameTwoLabel.text = isHaveFullCut? @"促销满减:" : @"";
            cell.nameTwoNumLabel.text = isHaveFullCut ? [NSString stringWithFormat:@"-￥%@",orderDetailForm.fullCutPrice] :  @"";
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount&&
                 indexPath.row <= itemCount + fullcutCount + 1)
        {
            CZJOrderProductFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductFooterCell" forIndexPath:indexPath];
            cell.fullCutLabel.hidden = YES;
            NSString* transportStr = [NSString stringWithFormat:@"+￥%.1f",[orderDetailForm.transportPrice floatValue]];
            cell.transportPriceLabel.text = transportStr;
            cell.totalLabel.text = [NSString stringWithFormat:@"￥%.1f",[orderDetailForm.orderMoney floatValue]];
            cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportStr AndFontSize:14].width + 10;
            return cell;
        }
        else if (indexPath.row > itemCount + fullcutCount + 1 &&
                 indexPath.row <= itemCount + fullcutCount + giftCount)
        {
            CZJGiftCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGiftCell" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            CZJLeaveMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJLeaveMessageCell" forIndexPath:indexPath];
            cell.leaveMessageLabel.text = @"";
            if (![orderDetailForm.note isEqualToString:@""]) {
                cell.leaveMessageView.hidden = YES;
                CGSize size = [CZJUtils calculateStringSizeWithString:orderDetailForm.note Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 30];
                cell.leaveMessageLabel.text = orderDetailForm.note;
                cell.leaveMessageLayoutHeight.constant = size.height;
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, size.height + 30);
            }
            else
            {
                cell.leaveMessageView.hidden = NO;
            }
            
            return cell;
        }

    }
    
    return nil;
}


#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 175;
        }
        if (1 == indexPath.row)
        {
            return 85;
        }
    }
    if (1 == indexPath.section)
    {
        NSInteger itemCount = orderDetailForm.items.count;
        NSInteger giftCount = 0;
        
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {
            return 108;

        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= itemCount + 2)
        {
            return 44;
        }
        else if (indexPath.row > itemCount + 2 &&
                 indexPath.row <= itemCount + 2 + giftCount)
        {
            return 30;
        }
        else if (indexPath.row > itemCount + 2 + giftCount &&
                 indexPath.row <= itemCount + 2 + giftCount + 1)
        {
            CGSize size = [CZJUtils calculateStringSizeWithString:orderDetailForm.note Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 30];
                return  60 + size.height;
        }
        else
        {
            return 44;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
