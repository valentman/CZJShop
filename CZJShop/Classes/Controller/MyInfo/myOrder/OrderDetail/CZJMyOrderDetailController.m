//
//  CZJMyOrderDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyOrderDetailController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderDetailCell.h"
#import "CZJDeliveryAddrCell.h"
#import "CZJOrderProductHeaderCell.h"
#import "CZJPromotionCell.h"
#import "CZJOrderProductFooterCell.h"
#import "CZJLeaveMessageCell.h"
#import "CZJGiftCell.h"
#import "CZJOrderBuilderCell.h"
#import "CZJOrderBuildCarCell.h"
#import "CZJOrderBuildingImagesCell.h"
#import "CZJOrderReturnedListCell.h"
#import "CZJCommentCell.h"
#import "CZJOrderListReturnedController.h"
#import "CZJOrderEvaluateController.h"
#import "CZJOrderBuildingController.h"
#import "CZJOrderLogisticsController.h"
#import "CZJOrderCarCheckController.h"
#import "CZJPopPayViewController.h"

@interface CZJMyOrderDetailController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJPopPayViewDelegate
>
{
    CZJOrderDetailForm* orderDetailForm;
    CZJReturnedOrderDetailForm* returnedOrdderDetailForm;
    CZJAddrForm* receiverAddrForm;
    NSDictionary* builderData;
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




- (IBAction)returnGoodsAction:(id)sender;
- (IBAction)viewCarCheckAction:(id)sender;
- (IBAction)payAction:(id)sender;
- (IBAction)confirmReceiveGoodsAction:(id)sender;
- (IBAction)viewLogisticsAction:(id)sender;
- (IBAction)cancelOrderAction:(id)sender;
- (IBAction)viewBuildingProgressAction:(id)sender;
- (IBAction)gotoEvaluateAction:(id)sender;
- (IBAction)contactServiceAction:(id)sender;
- (IBAction)cancelReturnGoodsAction:(id)sender;
- (IBAction)remindSellerAction:(id)sender;
@end

@implementation CZJMyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
        [self getOrderDetailFromServer];
        self.title = @"订单详情";
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        NSString* title = @"退换货详情";
        self.navigationItem.title = title;
        self.title = title;
        [self getReturnedOrderDetailFromServer];
    }
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.backgroundColor = CLEARCOLOR;
    self.view.backgroundColor = CZJNAVIBARGRAYBG;
    self.separatorViewHeight.constant = 0.5;
    
    NSArray* nibArys = @[@"CZJOrderDetailCell",
                         @"CZJDeliveryAddrCell",
                         @"CZJOrderProductHeaderCell",
                         @"CZJPromotionCell",
                         @"CZJOrderProductFooterCell",
                         @"CZJLeaveMessageCell",
                         @"CZJGiftCell",
                         @"CZJOrderBuilderCell",
                         @"CZJOrderBuildCarCell",
                         @"CZJOrderBuildingImagesCell",
                         @"CZJOrderReturnedListCell",
                         @"CZJCommentCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"订单详情";
}

- (void)getReturnedOrderDetailFromServer
{
    NSDictionary* params = @{@"orderItemPid":self.returnedGoodsForm.orderItemPid};
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        receiverAddrForm = [CZJAddrForm objectWithKeyValues:[dict valueForKey:@"receiver"]];
        returnedOrdderDetailForm = [CZJReturnedOrderDetailForm objectWithKeyValues:[dict valueForKey:@"item"]];
        stageNum = [returnedOrdderDetailForm.returnStatus integerValue] - 1;
        self.returnedDetailView.hidden = NO;
        orderType = 3;
        [self.myTableView reloadData];
    } andServerAPI:kCZJServerAPIGetMyReturnedOrderDetail];
}

- (void)getOrderDetailFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderDetail:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        builderData = [dict valueForKey:@"build"];
        orderDetailForm = [CZJOrderDetailForm objectWithKeyValues:dict];
        receiverAddrForm = orderDetailForm.receiver;
        [self.myTableView reloadData];
        
        if (!orderDetailForm.paidFlag)
        {
            //type==0为商品，type==1为服务
            if (0 == [orderDetailForm.type integerValue])
            {//商品未付款 永远只有等待买家付款的状态，也就是status == 0
                _stageStr = @"等待买家付款";
                stageNum = 0;
                orderType = 0;
                self.payCancleOrderView.hidden = NO;   //取消订单、付款
            }
            else if (1 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue]) {
                    _stageStr = @"等待买家付款";
                    stageNum = 0;
                    orderType = 0;
                    self.payCancleOrderView.hidden = NO;   //取消订单、付款
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                    _stageStr = @"等待门店施工(未付款)";
                    stageNum = 1;
                    orderType = 1;
                    self.carCheckView.hidden = NO; //取消订单、付款 、查看车检结果
                }
                else
                {
                    _stageStr = @"门店正在施工(未付款)";
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
                _stageStr = @"订单已完成";
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
                            _stageStr = @"卖家还没发货";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (2 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"卖家还没发货";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (3 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"等待买家收货";
                            self.noReceiveView.hidden = NO;  //退换货、查看物流、确认收货
                        }
                    }
                    else if (1 == [orderDetailForm.type integerValue])
                    {
                        if (0 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"等待到店施工";
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (1 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"等待门店施工";
                            self.cancleCarCheckView.hidden = NO; //取消订单、查看车检结果
                        }
                        else if (2 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"门店正在施工";
                            self.carCheckBuildingProgressView.hidden = NO; //查看车检结果、查看施工进度
                        }
                        else if (3 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"门店正在施工";
                            self.carCheckBuildingProgressView.hidden = NO; //查看车检结果、查看施工进度
                        }
                    }
                }
                else
                {
                    _stageStr = @"等待买家评价";
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
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
        if ([orderDetailForm.type floatValue] == 1 &&
            [orderDetailForm.status floatValue] >= 2)
        {
            return 5;
        }
        return 2;
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1 + (receiverAddrForm.receiver == nil ? 0 : 1);
    }
    
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
        if (1 == section)
        {
            return  4 + orderDetailForm.items.count;
        }
        if (2 == section ||
            3 == section)
        {
            return 1;
        }
        if (4 == section)
        {
            return 2;
        }
        return 3;
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderDetailCell" forIndexPath:indexPath];
            [cell setOrderStateLayout:stageNum type:orderType];
            cell.stageLabel.text = _stageStr;
            if (CZJOrderDetailTypeReturned == self.orderDetailType)
            {
                cell.orderTimeTitleLabel.text = @"申请时间:";
                cell.leftTimeLabel.hidden = YES;
            }
            cell.orderNoLabel.text = CZJOrderDetailTypeGeneral == self.orderDetailType ? orderDetailForm.orderNo : returnedOrdderDetailForm.orderNo;
            cell.orderTimeLabel.text = CZJOrderDetailTypeGeneral == self.orderDetailType ?orderDetailForm.createTime:returnedOrdderDetailForm.returnTime;

            if (stageLabelColor)
            {
                cell.stageLabel.textColor = stageLabelColor;
            }
            cell.stageLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:_stageStr WithFont:BOLDSYSTEMFONT(15)].width + 5;
            if (!orderDetailForm.paidFlag &&
                CZJOrderDetailTypeGeneral == self.orderDetailType) {
                cell.leftTimeLabel.hidden = [orderDetailForm.timeOver isEqualToString:@""];
                cell.leftTimeLabel.text = [NSString stringWithFormat:@"剩余%@",orderDetailForm.timeOver];
            }
            else
            {
                cell.leftTimeLabel.hidden = YES;
            }
            cell.separatorInset = UIEdgeInsetsMake(175, 20, 0, 20);
            return cell;
        }
        else if (1 == indexPath.row)
        {
            CZJDeliveryAddrCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrCell" forIndexPath:indexPath];
            cell.deliveryNameLabel.text = receiverAddrForm.receiver;
            cell.deliveryAddrLabel.text = receiverAddrForm.addr;
            cell.contactNumLabel.text = receiverAddrForm.mobile;
            cell.defaultLabel.hidden = YES;
            cell.deliveryAddrLayoutLeading.constant = 41;
            cell.commitNextArrowImg.hidden = YES;
            return cell;
        }
    }
    
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        if (0 == indexPath.row)
        {
            CZJOrderReturnedListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderReturnedListCell" forIndexPath:indexPath];
            [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:IMAGENAMED(@"")];
            cell.goodNameLabel.text = self.returnedGoodsForm.itemName;
            cell.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",self.returnedGoodsForm.currentPrice];
            cell.goodModelLabel.text = self.returnedGoodsForm.itemSku;
            cell.returnBtn.hidden = YES;
            return cell;
        }
        if (1 == indexPath.row)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"resonCell"];
            if (!cell)
            {
                 cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resonCell"];
            }
            cell.detailTextLabel.text = returnedOrdderDetailForm.returnReason;
            cell.detailTextLabel.textColor = LIGHTGRAYCOLOR;
            cell.detailTextLabel.font = SYSTEMFONT(13);
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCommentCell" forIndexPath:indexPath];
            cell.commentLabel.text = returnedOrdderDetailForm.returnNote;
            cell.commentLabel.textColor = LIGHTGRAYCOLOR;
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        
    }
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
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
                cell.separatorInset = UIEdgeInsetsMake(44, -20, 0, 0);
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
                
                if (goodsForm.setupFlag)
                {
                    cell.arrowImg.hidden = YES;
                    cell.selectedSetupStoreNameLabel.text = goodsForm.setupStoreName;
                    cell.storeNameLabelTailing.constant = 15;
                    
                }
                cell.separatorInset = UIEdgeInsetsMake(goodsForm.setupFlag ? 138 : 108, 20, 0, 20);
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
                cell.separatorInset = HiddenCellSeparator;
                return cell;
            }
            else if (indexPath.row > itemCount + fullcutCount&&
                     indexPath.row <= itemCount + fullcutCount + 1)
            {
                CZJOrderProductFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderProductFooterCell" forIndexPath:indexPath];
                cell.fullCutLabel.hidden = YES;
                cell.setupPriceLabel.hidden = YES;
                cell.setupLabel.hidden = YES;
                
                NSString* transportStr = [NSString stringWithFormat:@"+￥%.1f",[orderDetailForm.transportPrice floatValue]];
                cell.transportPriceLabel.text = transportStr;
                cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportStr AndFontSize:14].width + 10;
                
                NSString* totalStr = [NSString stringWithFormat:@"￥%.1f",[orderDetailForm.orderMoney floatValue]];
                cell.totalLabel.text = totalStr;
                cell.totalPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:totalStr AndFontSize:17].width + 10;
                
                if ([orderDetailForm.setupPrice floatValue] > 0.01)
                {
                    cell.setupPriceLabel.hidden = NO;
                    cell.setupLabel.hidden = NO;
                    NSString* setupStr = [NSString stringWithFormat:@"+￥%.1f",[orderDetailForm.setupPrice floatValue]];
                    cell.setupPriceLabel.text = setupStr;
                    cell.setupPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:setupStr AndFontSize:14].width + 10;
                }
                
                cell.separatorInset = HiddenCellSeparator;
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
                cell.separatorInset = HiddenCellSeparator;
                return cell;
            }
            
        }
        
        if (2 == indexPath.section)
        {
            CZJOrderBuildCarCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildCarCell" forIndexPath:indexPath];
            [cell.carBrandImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:IMAGENAMED(@"default_icon_car")];
            NSString* carBrandName = [[builderData valueForKey:@"car"] valueForKey:@"brandName"];
            NSString* carSeriesName = [[builderData valueForKey:@"car"] valueForKey:@"seriesName"];
            NSString* carNumberPlate = [[builderData valueForKey:@"car"] valueForKey:@"numberPlate"];
            cell.myCarInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %@",carBrandName, carSeriesName, carNumberPlate];
            cell.myCarModelLabel.text = [[builderData valueForKey:@"car"] valueForKey:@"modelName"];
            return cell;
        }
        if (3 == indexPath.section)
        {
            CZJOrderBuilderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuilderCell" forIndexPath:indexPath];
            
            //施工人员头像
            [cell.builderHeadImg sd_setImageWithURL:[NSURL URLWithString:[builderData valueForKey:@"head"]] placeholderImage:IMAGENAMED(@"order_head_default.png")];
            
            //施工人员名称和施工状态
            NSString* builderNameStr =[builderData valueForKey:@"builder"] == nil ? @"" : [builderData valueForKey:@"builder"];
            NSString* buildStatusStr;
            NSInteger offset = 0;
            NSInteger leading;
            NSInteger builderNameWidth = [CZJUtils calculateStringSizeWithString:builderNameStr Font:SYSTEMFONT(15) Width:100].width;
            if (0 != builderNameWidth)
            {
                leading = 5;
                offset = 30;
            }
            else
            {
                leading = -60;
            }
            
            if ([orderDetailForm.status floatValue] == 2 ||
                [orderDetailForm.status floatValue] == 3)
            {
                
                buildStatusStr = @"正在施工";
            }
            if ([orderDetailForm.status floatValue] == 4)
            {
                buildStatusStr = @"已完成施工";
            }
            cell.builderNameOffset.constant = offset;
            cell.builderNameLabel.text = builderNameStr;
            cell.buildingLabel.text = buildStatusStr;
            cell.buildingLabelLeading.constant = leading;
            
            //用时
            NSString* useTimeStr = [NSString stringWithFormat:@"已用时%@",[builderData valueForKey:@"useTime"] == nil ? @"" : [builderData valueForKey:@"useTime"]];
            if ([orderDetailForm.status floatValue] == 4)
            {
                useTimeStr = @"请顾客前往取车";
            }
            CGSize size = [CZJUtils calculateTitleSizeWithString:useTimeStr AndFontSize:12];
            cell.leftTimeLabelWidth.constant = size.width + 5;
            cell.leftTimeLabel.text = useTimeStr;
            
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        if (4 == indexPath.section)
        {
            if (0 == indexPath.row)
            {
                CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
                cell.myTitleLabel.text = @"施工图片";
                cell.separatorInset = HiddenCellSeparator;
                return cell;
            }
            else
            {
                UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                NSArray* photosAry = [builderData valueForKey:@"photos"];
                for (int i = 0; i< photosAry.count; i++)
                {
                    UIImageView* image = [[UIImageView alloc]init];
                    image.frame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:4];
                    [cell addSubview:image];
                    [image sd_setImageWithURL:[NSURL URLWithString:photosAry[i]] placeholderImage:IMAGENAMED(@"")];
                }
                if (photosAry.count == 0)
                {
                    UILabel* textlabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 15)];
                    [cell addSubview:textlabel];
                    
                    textlabel.text = @"暂未拍照";
                    textlabel.textColor = [UIColor lightGrayColor];
                    textlabel.font = SYSTEMFONT(12);
                }
                cell.separatorInset = HiddenCellSeparator;
                return cell;
            }
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
    
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
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
                CZJOrderGoodsForm* goodsForm = orderDetailForm.items[indexPath.row - 1];
                if (goodsForm.setupFlag)
                {
                    return 138;
                }
                return 108;
                
            }
            else if (indexPath.row > itemCount &&
                     indexPath.row <= itemCount + 2)
            {
                return 30;
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
                return  50 + size.height;
            }
            else
            {
                return 44;
            }
        }
        if (2 == indexPath.section)
        {
            return 82;
        }
        if (3 == indexPath.section)
        {
            return 167;
        }
        if (4 == indexPath.section)
        {
            if (0 == indexPath.row)
            {
                return 44;
            }
            if (1 == indexPath.row)
            {
                if (((NSArray*)[builderData valueForKey:@"photos"]).count > 0)
                {
                    return 100;
                }
                //动态调整的
                return 44;
            }
        }
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        if (0 == indexPath.row)
        {
            return 110;
        }
        if (1 == indexPath.row)
        {
            return 150;
        }
        if (2 == indexPath.row)
        {
            return 100;
        }
    }
    


    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section ||
        4 == section)
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
    if ([segue.identifier isEqualToString:@"orderDetailToRetuableOrderList"]) {
        CZJOrderListReturnedController* returnListVC = segue.destinationViewController;
        returnListVC.returnListType = CZJReturnListTypeReturnable;
        returnListVC.orderNo = self.orderNo;
    }
    if ([segue.identifier isEqualToString:@"segueToLogistics"])
    {
        CZJOrderLogisticsController* logisticsVC = segue.destinationViewController;
        logisticsVC.orderNo = self.orderNo;
    }
    if ([segue.identifier isEqualToString:@"orderDetailToBuilding"])
    {
        CZJOrderBuildingController* buildingVC = segue.destinationViewController;
        buildingVC.orderNo = self.orderNo;
    }
    if ([segue.identifier isEqualToString:@"orderDetailToEvaluate"])
    {
        CZJOrderEvaluateController* evaluateVC = segue.destinationViewController;
        evaluateVC.evaluateGoodsAry = orderDetailForm.items;
        evaluateVC.orderNo = self.orderNo;
    }
    if ([segue.identifier isEqualToString:@"orderDetailToCarCheck"])
    {
        CZJOrderCarCheckController* carCheckVC = segue.destinationViewController;
        carCheckVC.orderNo = self.orderNo;
    }
}

- (void)showPopPayView:(float)orderMoney
{
    CZJPopPayViewController* payPopView = [[CZJPopPayViewController alloc]init];
    payPopView.delegate = self;
    payPopView.orderMoney = orderMoney;
    
    self.popWindowInitialRect = VERTICALHIDERECT(320);
    self.popWindowDestineRect = VERTICALSHOWRECT(320);
    [CZJUtils showMyWindowOnTarget:self withMyVC:payPopView];
    __weak typeof(self) weak = self;
    [payPopView setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = self.popWindowInitialRect;
            weak.upView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [weak.upView removeFromSuperview];
                [weak.window resignKeyWindow];
                weak.window  = nil;
                weak.upView = nil;
                weak.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        }];
    }];
}

#pragma mark- CZJPopPayViewDelegate
- (void)payViewToPay:(id)sender
{
    
}


#pragma mark - Actions
- (IBAction)returnGoodsAction:(id)sender
{
    [self performSegueWithIdentifier:@"orderDetailToRetuableOrderList" sender:self];
}

- (IBAction)viewCarCheckAction:(id)sender
{
    [self performSegueWithIdentifier:@"orderDetailToCarCheck" sender:self];
}

- (IBAction)payAction:(id)sender
{
    [self showPopPayView:[orderDetailForm.orderMoney floatValue]];
}

- (IBAction)confirmReceiveGoodsAction:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"你要想好哦，确认收货就不能退款了哦" andHandler:^{
        [CZJBaseDataInstance generalPost:@{} success:^(id json) {
            [weak.myTableView reloadData];
        } andServerAPI:kCZJServerAPIReceiveGoods];
        [weak hideWindow];
    }];
}

- (IBAction)viewLogisticsAction:(id)sender
{
    [self performSegueWithIdentifier:@"segueToLogistics" sender:self];
}

- (IBAction)cancelOrderAction:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确定取消该订单" andHandler:^{
        [CZJBaseDataInstance generalPost:@{} success:^(id json) {
            
        } andServerAPI:kCZJServerAPICancelOrder];
        [weak hideWindow];
    }];
}

- (IBAction)viewBuildingProgressAction:(id)sender
{
    [self performSegueWithIdentifier:@"orderDetailToBuilding" sender:self];
}

- (IBAction)gotoEvaluateAction:(id)sender
{
    [self performSegueWithIdentifier:@"orderDetailToEvaluate" sender:self];
}

- (IBAction)contactServiceAction:(id)sender
{
    DLog(@"联系客服");
}

- (IBAction)cancelReturnGoodsAction:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确定取消退换货" andHandler:^{
        [CZJBaseDataInstance generalPost:nil success:^(id json) {
            
        } andServerAPI:kCZJServerAPICancelReturnOrder];
        [weak hideWindow];
    }];
}

- (IBAction)remindSellerAction:(id)sender
{
    DLog(@"提醒卖家");
}
@end
