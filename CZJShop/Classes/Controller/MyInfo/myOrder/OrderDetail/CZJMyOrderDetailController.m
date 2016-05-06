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
#import "CZJPaymentManager.h"
#import "OpenShareHeader.h"

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
    
    NSString* orderNoString;
    float totalMoney;
    CZJGeneralBlock hidePayViewBlock;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myTableViewButtom;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeight;

//确认收货 查看物流
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

//退换货、去评价
@property (weak, nonatomic) IBOutlet UIView *returnOrEvaluate;
@property (weak, nonatomic) IBOutlet UIView *returnOnly;

//联系车之健 取消退换货 提醒卖家同意
@property (weak, nonatomic) IBOutlet UIView *returnedDetailView;
@property (weak, nonatomic) IBOutlet UIView *cancleReturnView;

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
@end

@implementation CZJMyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    NSString* title = @"";
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
        title = @"订单详情";
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        title = @"退换货详情";
    }
    self.naviBarView.mainTitleLabel.text = title;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (CZJOrderDetailTypeGeneral == self.orderDetailType)
    {
        [self getOrderDetailFromServer];
    }
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {
        [self getReturnedOrderDetailFromServer];
    }
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.backgroundColor = CLEARCOLOR;
    self.myTableView.hidden = YES;
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
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
    
}

- (void)getReturnedOrderDetailFromServer
{
    NSDictionary* params = @{@"orderItemPid":self.returnedGoodsForm.orderItemPid};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].color = GRAYCOLOR;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"return:%@",[dict description]);
        receiverAddrForm = [CZJAddrForm objectWithKeyValues:[dict valueForKey:@"receiver"]];
        returnedOrdderDetailForm = [CZJReturnedOrderDetailForm objectWithKeyValues:[dict valueForKey:@"item"]];
        stageNum = [returnedOrdderDetailForm.returnStatus integerValue] - 1;
        orderType = 3;
        
        switch ([returnedOrdderDetailForm.returnStatus integerValue])
        {
            case 1:
                self.cancleReturnView.hidden = NO;
                _stageStr = @"等待卖家同意";
                break;
            case 2:
                self.cancleReturnView.hidden = NO;
                _stageStr = @"卖家已同意，请寄回商品";
                break;
            case 3:
                self.cancleReturnView.hidden = NO;
                _stageStr = @"卖家已收货";
                break;
            case 4:
                stageLabelColor = UIColorFromRGB(0x48AB11);
                _stageStr = [returnedOrdderDetailForm.returnType isEqualToString:@"1"] ? @"退货成功" : @"换货成功";
                self.myTableViewButtom.constant = 0;
                self.buttomLineView.hidden = YES;
                break;
                
            default:
                break;
        }
        [self.myTableView reloadData];
        self.myTableView.hidden = NO;
    }  fail:^{
        DLog(@"");
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } andServerAPI:kCZJServerAPIGetMyReturnedOrderDetail];
}

- (void)getOrderDetailFromServer
{
    __weak typeof(self) weak = self;
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].color = GRAYCOLOR;
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJBaseDataInstance getOrderDetail:params Success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"%@",[dict description]);
        builderData = [dict valueForKey:@"build"];
        orderDetailForm = [CZJOrderDetailForm objectWithKeyValues:dict];
        receiverAddrForm = orderDetailForm.receiver;
        
        //-----------------------------------未付款----------------------------------
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
            else if (2 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue]) {
                    _stageStr = @"等待买家付款";
                    stageNum = 0;
                    orderType = 0;
                    self.payCancleOrderView.hidden = NO;   //取消订单、付款
                }
            }
        }
        
        //-----------------------------------已付款----------------------------------
        else
        {
            if (orderDetailForm.evaluated)
            {//
                stageLabelColor = UIColorFromRGB(0x48AB11);
                _stageStr = @"订单已完成";
                stageNum = 3;
                orderType = 0;
                if ( 0 == [orderDetailForm.type integerValue])
                {
                    self.buttomLineView.hidden = YES;
                    self.returnOnly.hidden = !orderDetailForm.returnFlag;
                }
                else if (1 == [orderDetailForm.type integerValue])
                {
                    self.onlyCarCheckView.hidden = NO;  //查看车检结果
                }
                else if (2 == [orderDetailForm.type integerValue])
                {
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
                            stageNum = 2;
                            _stageStr = @"等待买家收货";
                            self.noReceiveView.hidden = NO;  //退换货、查看物流、确认收货
                        }
                    }
                    else if (1 == [orderDetailForm.type integerValue])
                    {
                        orderType = 1;
                        if (0 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"等待到店施工";
                            stageNum = 1;
                            self.cancelOrderView.hidden = NO;   //取消订单
                        }
                        else if (1 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"等待门店施工";
                            stageNum = 1;
                            self.cancleCarCheckView.hidden = NO; //取消订单、查看车检结果
                        }
                        else if (2 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"门店正在施工";
                            stageNum = 1;
                            self.onlyCarCheckView.hidden = NO; //查看车检结果、查看施工进度
                        }
                        else if (3 == [orderDetailForm.status integerValue])
                        {
                            _stageStr = @"门店已完成施工";
                            stageNum = 2;
                            self.onlyCarCheckView.hidden = NO; //查看车检结果、查看施工进度
                        }
                    }
                }
                else
                {
                    stageLabelColor = UIColorFromRGB(0x48AB11);
                    _stageStr = @"订单已完成";
                    stageNum = 3;
                    orderType = 0;
                    if (2 == [orderDetailForm.type integerValue] )
                    {
                        self.goEvaluateView.hidden = NO;            //去评价
                    }
                    if (0 == [orderDetailForm.type integerValue])
                    {
                        self.returnOrEvaluate.hidden = NO;        //退换货、去评价
                    }
                    if (1 == [orderDetailForm.type integerValue])
                    {
                        self.carCheckEvaluateView.hidden = NO;      //查看车检结果、去评价
                    }
                }
            }
        }
        
        //-----------------------------------数据刷新----------------------------------
        [self.myTableView reloadData];
        self.myTableView.hidden = NO;
        
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getOrderDetailFromServer];
        }];
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
        return 1 + ([receiverAddrForm.receiver isEqualToString:@""] ? 0 : 1);
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
    //=============订单进度，收货地址为固定区域=============
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
            if (CZJOrderDetailTypeReturned == self.orderDetailType)
            {
                if ([returnedOrdderDetailForm.returnType isEqualToString:@"1"])
                {
                    [cell.deliverLocaitonIMg setImage:IMAGENAMED(@"order_icon_tui")];
                }
                else
                {
                    [cell.deliverLocaitonIMg setImage:IMAGENAMED(@"order_icon_huan")];
                }
            }
            return cell;
        }
    }
    
    //=============详情区域需要区分是退货订单详情，还是一般订单详情=============
    if (CZJOrderDetailTypeReturned == self.orderDetailType)
    {//退换货订单详情
        if (0 == indexPath.row)
        {
            CZJOrderReturnedListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderReturnedListCell" forIndexPath:indexPath];
            [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:self.returnedGoodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
            cell.goodNameLabel.text = self.returnedGoodsForm.itemName;
            cell.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",self.returnedGoodsForm.currentPrice];
            cell.goodModelLabel.text = self.returnedGoodsForm.itemSku;
            cell.returnBtn.hidden = YES;
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"resonCell"];
            if (!cell)
            {
                 cell = [[CZJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resonCell"];
            }
            
            if (returnedOrdderDetailForm && !cell.isInit)
            {
                cell.isInit = YES;
                int labeiHeight = [CZJUtils calculateStringSizeWithString:returnedOrdderDetailForm.returnReason Font:SYSTEMFONT(14) Width:PJ_SCREEN_WIDTH - 30].height;
                labeiHeight = labeiHeight < 20 ? 20 : labeiHeight;
                UILabel* contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, PJ_SCREEN_WIDTH - 30, labeiHeight)];
                contentLabel.textAlignment = NSTextAlignmentLeft;
                contentLabel.font = SYSTEMFONT(14);
                contentLabel.textColor = RGB(192, 192, 192);
                contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
                contentLabel.text = returnedOrdderDetailForm.returnReason;
                [cell addSubview:contentLabel];
                
                NSInteger count = returnedOrdderDetailForm.returnImgs.count;
                for (int i = 0; i < count; i++)
                {
                    CZJImageView* returnimage = [[CZJImageView alloc]init];
                    returnimage.subTag = i;
                    [returnimage sd_setImageWithURL:[NSURL URLWithString:returnedOrdderDetailForm.returnImgs[i]] placeholderImage:DefaultPlaceHolderSquare];
                    CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:4];
                    returnimage.frame = CGRectMake(imageFrame.origin.x, imageFrame.origin.y + labeiHeight + 10, 78, 78);
                    [returnimage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)]];
                    [cell addSubview:returnimage];
                }
            }
            
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
    {//一般订单详情
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
                
                //商品图片
                [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
                
                //商品名称
                cell.goodsNameLabel.text = goodsForm.itemName;
                cell.goodsNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 78 -15 - 8 - 15;
                
                //商品SKU
                cell.goodsTypeLabel.text = goodsForm.itemSku;
                
                //商品价格
                NSString* priceStr = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
                cell.priceLabel.text = priceStr;
                cell.priceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:priceStr AndFontSize:13].width + 5;
                
                //商品数量
                cell.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
                
                //单个商品小计总价
                float perGoodsTotalPrice = [goodsForm.itemCount integerValue] * [goodsForm.currentPrice floatValue];
                cell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",perGoodsTotalPrice];
                
                if (goodsForm.setupFlag)
                {
                    cell.setupView.hidden = NO;
                    cell.arrowImg.hidden = YES;
                    cell.selectedSetupStoreNameLabel.hidden = NO;
                    cell.selectedSetupStoreNameLabel.text = goodsForm.selectdSetupStoreName == nil? @"自行安装" : goodsForm.selectdSetupStoreName;
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
                cell.nameOneNumLabel.text = [NSString stringWithFormat:@"-￥%.2f", [orderDetailForm.couponPrice floatValue]];
                
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
                
                NSString* transportStr = [NSString stringWithFormat:@"+￥%.2f",[orderDetailForm.transportPrice floatValue]];
                cell.transportPriceLabel.text = transportStr;
                cell.transportPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:transportStr AndFontSize:14].width + 10;
                
                NSString* totalStr = [NSString stringWithFormat:@"￥%.2f",[orderDetailForm.orderMoney floatValue]];
                cell.totalLabel.text = totalStr;
                cell.totalPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:totalStr AndFontSize:17].width + 10;
                
                if ([orderDetailForm.setupPrice floatValue] > 0.01)
                {
                    cell.setupPriceLabel.hidden = NO;
                    cell.setupLabel.hidden = NO;
                    NSString* setupStr = [NSString stringWithFormat:@"+￥%.2f",[orderDetailForm.setupPrice floatValue]];
                    cell.setupPriceLabel.text = setupStr;
                    cell.setupPriceLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:setupStr AndFontSize:14].width + 10;
                }
                
                cell.separatorInset = HiddenCellSeparator;
                return cell;
            }
            else if (indexPath.row > itemCount + fullcutCount + 1 &&
                     indexPath.row <= itemCount + fullcutCount + 1 + giftCount)
            {
                CZJShoppingGoodsInfoForm* giftForm = orderDetailForm.gifts[indexPath.row - (itemCount + fullcutCount + 2)];
                CZJGiftCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGiftCell" forIndexPath:indexPath];
                cell.giftName.text = giftForm.itemName;
                [cell.giftItemImg sd_setImageWithURL:[NSURL URLWithString:giftForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
                cell.separatorInset = HiddenCellSeparator;
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
            [cell.carBrandImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:DefaultPlaceHolderSquare];
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
            [cell.builderHeadImg sd_setImageWithURL:[NSURL URLWithString:[builderData valueForKey:@"head"]] placeholderImage:IMAGENAMED(@"personal_icon_head")];
            
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
                    CZJImageView* image = [[CZJImageView alloc]init];
                    image.subTag = i;
                    image.frame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:4];
                    [cell addSubview:image];
                    [image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",photosAry[i],SUOLUE_PIC_200]] placeholderImage:DefaultPlaceHolderSquare];
                    [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)]];
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
            if (returnedOrdderDetailForm)
            {
                int labeiHeight = [CZJUtils calculateStringSizeWithString:returnedOrdderDetailForm.returnReason Font:SYSTEMFONT(14) Width:PJ_SCREEN_WIDTH - 30].height;
                labeiHeight = labeiHeight < 20 ? 20 : labeiHeight;
                NSInteger count = returnedOrdderDetailForm.returnImgs.count;
                if (count>5)
                {
                    return 156 + labeiHeight + 20;
                }
                else
                {
                    return 78 + labeiHeight + 20;
                }
            }
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
        evaluateVC.orderDetailForm = orderDetailForm;
        evaluateVC.orderNo = self.orderNo;
    }
    if ([segue.identifier isEqualToString:@"orderDetailToCarCheck"])
    {
        CZJOrderCarCheckController* carCheckVC = segue.destinationViewController;
        carCheckVC.orderNo = self.orderNo;
    }
}

- (void)showPopPayView:(float)orderMoney andOrderNoSting:(NSString*)orderNostr
{
    orderNoString = orderNostr;
    totalMoney = orderMoney;
    CZJPopPayViewController* payPopView = [[CZJPopPayViewController alloc]init];
    payPopView.delegate = self;
    payPopView.orderMoney = orderMoney;
    
    float popViewHeight = CZJBaseDataInstance.orderPaymentTypeAry.count * 70 + 60 +50.5;
    self.popWindowInitialRect = VERTICALHIDERECT(0);
    self.popWindowDestineRect = VERTICALSHOWRECT(popViewHeight);
    [CZJUtils showMyWindowOnTarget:self withPopVc:payPopView];
    __weak typeof(self) weak = self;
    
    hidePayViewBlock = ^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = weak.popWindowInitialRect;
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
    };
    [payPopView setCancleBarItemHandle:hidePayViewBlock];
}

#pragma mark- CZJPopPayViewDelegate
 - (void)payViewToPay:(id)sender
{
    CZJOrderTypeForm* selectOrderTypeForm = (CZJOrderTypeForm*)sender;
    NSDictionary* params = @{@"orderIds" : orderNoString, @"totalMoney" : [NSString stringWithFormat:@"%.2f",totalMoney]};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils performBlock:hidePayViewBlock afterDelay:0.5];
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        CZJPaymentOrderForm* paymentOrderForm = [[CZJPaymentOrderForm alloc] init];
        paymentOrderForm.order_no = [dict valueForKey:@"payNo"];
        paymentOrderForm.order_name = [NSString stringWithFormat:@"订单%@",[dict valueForKey:@"payNo"]];
        paymentOrderForm.order_description = @"支付宝你个SB";
        paymentOrderForm.order_price = [dict valueForKey:@"totalMoney"];
        paymentOrderForm.order_for = @"pay";
        if ([selectOrderTypeForm.orderTypeName isEqualToString:@"微信支付"])
        {
            if ([OpenShare isWeixinInstalled])
            {
                [CZJPaymentInstance weixinPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                    DLog(@"微信支付成功");
                } Fail:^(NSDictionary *message, NSError *error) {
                    [CZJUtils tipWithText:@"微信支付失败" andView:weak.view];
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装微信客户端，请安装后支付" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
        if ([selectOrderTypeForm.orderTypeName isEqualToString:@"支付宝支付"])
        {
            if ([OpenShare isAlipayInstalled])
            {
                [CZJPaymentInstance aliPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
                    DLog(@"支付宝支付成功");
                } Fail:^(NSDictionary *message, NSError *error) {
                    [CZJUtils tipWithText:@"支付宝支付失败" andView:weak.view];
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装支付宝客户端，请安装后支付" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIOrderToPay];
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
    [self showPopPayView:[orderDetailForm.orderMoney floatValue] andOrderNoSting:orderDetailForm.orderNo];
}

- (IBAction)confirmReceiveGoodsAction:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"亲,是否确认收货" andConfirmHandler:^{
        [CZJBaseDataInstance generalPost:@{@"orderNo":orderDetailForm.orderNo} success:^(id json) {
            [weak getOrderDetailFromServer];
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshOrderlist object:nil];
        } fail:^{
            
        } andServerAPI:kCZJServerAPIReceiveGoods];
        [weak hideWindow];
    }  andCancleHandler:nil];
}

- (IBAction)viewLogisticsAction:(id)sender
{
    [self performSegueWithIdentifier:@"segueToLogistics" sender:self];
}

- (IBAction)cancelOrderAction:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确定取消该订单" andConfirmHandler:^{
        [CZJBaseDataInstance generalPost:@{@"orderNo":orderDetailForm.orderNo} success:^(id json) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshOrderlist object:nil];
            [weak.navigationController popViewControllerAnimated:YES];
        }  fail:^{
            
        } andServerAPI:kCZJServerAPICancelOrder];
        [weak hideWindow];
    } andCancleHandler:nil];
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
    [self showCZJAlertView:@"确定取消退换货" andConfirmHandler:^{
        [CZJBaseDataInstance generalPost:nil success:^(id json) {
            [CZJUtils tipWithText:@"取消退换货成功" andView:self.view];
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshReturnOrderlist object:nil];
            [weak.navigationController popViewControllerAnimated:YES];
        }  fail:^{
            
        } andServerAPI:kCZJServerAPICancelReturnOrder];
        [weak hideWindow];
    } andCancleHandler:nil];
}

- (IBAction)remindSellerAction:(id)sender
{
    DLog(@"提醒卖家");
}


#pragma mark- 点小图显示大图
- (void)showBigImage:(UIGestureRecognizer*)recogonizer
{
    CZJImageView* evalutionImg = (CZJImageView*)recogonizer.view;
    
    if (_orderDetailType == CZJOrderDetailTypeGeneral) {
        [CZJUtils showDetailInfoWithIndex:evalutionImg.subTag withImgAry:orderDetailForm.build.photos onTarget:self];
    }
    if (_orderDetailType == CZJOrderDetailTypeReturned)
    {
        [CZJUtils showDetailInfoWithIndex:evalutionImg.subTag withImgAry:returnedOrdderDetailForm.returnImgs onTarget:self];
    }
}
@end
