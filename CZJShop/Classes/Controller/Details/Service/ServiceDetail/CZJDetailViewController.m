//
//  CZJDetailViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailViewController.h"
#import "NIDropDown.h"
#import "CZJBaseDataManager.h"
#import "CZJPageControlView.h"
#import "CZJDetailForm.h"
#import "CZJDetailDescCell.h"
#import "CZJDetailPicShowCell.h"
#import "CZJChoosedProductCell.h"
#import "CZJCouponsCell.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJEvalutionHeaderCell.h"
#import "CZJStoreInfoHeaerCell.h"
#import "CZJStoreInfoCell.h"
#import "CZJHotRecommendCell.h"
#import "CZJOrderTypeExpandCell.h"
#import "WyzAlbumViewController.h"
#import "CZJChooseProductTypeController.h"
#import "CZJReceiveCouponsController.h"
#import "CZJPicDetailController.h"
#import "CZJBuyNoticeController.h"
#import "CZJAfterServiceController.h"
#import "CZJApplicableCarController.h"
#import "CZJGoodsDetailForm.h"
#import "CZJStoreForm.h"
#import "CZJCommitOrderController.h"


#define kTagScrollView 1002
#define kTagTableView 1001

@interface CZJDetailViewController ()
<
NIDropDownDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate,
CZJStoreInfoHeaerCellDelegate
>
{
    NIDropDown *dropDown;
    BOOL isScorllUp;
    
    CGFloat tableViewContentSizeHeight;
    BOOL isButtom;
    
    //当前页面数据
    CZJGoodsDetailForm* goodsDetailForm;            //详情界面总数据
    CZJStoreInfoForm* _storeInfo;                   //服务门店信息
    CZJDetailEvalInfo* _evalutionInfo;              //服务评价简介
    CZJGoodsDetail* _goodsDetail;                   //商品信息
    NSArray* _couponForms;                          //领券列表
    NSArray* _recommendServiceForms;                //推荐服务列表
    
    CZJChoosedProductCell* chooosedProductCell;     //已选商品cell，定义成成员变量是为了方便传值
    
    NSMutableArray* _settleOrderAry;
}
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIView *borderLineView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *shoppingCartView;
@property (weak, nonatomic) IBOutlet UIButton *addProductToShoppingCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyImeditelyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderLineLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProductToWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *immediatelyBuyWidth;

@property (strong, nonatomic) UITableView* detailTableView;

- (IBAction)immediatelyBuyAction:(id)sender;
- (IBAction)addProductToShoppingCartAction:(id)sender;
- (IBAction)attentionAction:(id)sender;
- (IBAction)contactServiceAction:(id)sender;
- (IBAction)storeAction:(id)sender;


@end

@implementation CZJDetailViewController
@synthesize storeItemPid = _storeItemPid;

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeDetail];
    [self initDatas];
    [self initViews];
    [SVProgressHUD show];
    [SVProgressHUD setBackgroundColor:CLEARCOLOR];
    [CZJUtils performBlock:^{
        [self getDataFromServer];
    } afterDelay:0.5];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.naviBarView refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registNotification];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiRefreshDetailView object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiPicDetailBack object:nil];
}

- (void)initDatas
{
    _recommendServiceForms = [NSArray array];
    _couponForms = [NSArray array];
    _settleOrderAry = [NSMutableArray array];
}

- (void)initViews
{
    self.borderLineLayoutHeight.constant = 0.5;
    self.borderLineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02") forState:UIControlStateNormal];
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02_sel") forState:UIControlStateSelected];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    
    //背景Scrollview
    self.myScrollView.contentSize = CGSizeMake(PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-50)*2 - 64);
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.scrollEnabled = NO;
    self.myScrollView.delegate = self;
    self.myScrollView.tag = kTagScrollView;
    self.myScrollView.showsVerticalScrollIndicator = NO;
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    
    
    //详情TableView
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-50)) style:UITableViewStylePlain];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    _detailTableView.showsVerticalScrollIndicator = NO;
    _detailTableView.backgroundColor = [UIColor whiteColor];
    _detailTableView.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSArray* nibArys = @[ @"CZJDetailDescCell",
                          @"CZJDetailPicShowCell",
                          @"CZJChoosedProductCell",
                          @"CZJCouponsCell",
                          @"CZJEvalutionDescCell",
                          @"CZJEvalutionFooterCell",
                          @"CZJEvalutionHeaderCell",
                          @"CZJStoreInfoCell",
                          @"CZJHotRecommendCell",
                          @"CZJStoreInfoHeaerCell",
                          @"CZJOrderTypeExpandCell"
                          ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.detailTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    _detailTableView.tag = kTagTableView;
    self.detailTableView.tableFooterView = [[UIView alloc] init];
    [self.myScrollView addSubview:_detailTableView];
    [self.detailTableView reloadData];
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDetailData:) name:kCZJNotifiRefreshDetailView  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(picDetailViewBack:) name:kCZJNotifiPicDetailBack object:nil];
}

- (void)reloadDetailData:(NSNotification*)notif
{
    self.storeItemPid = [notif.userInfo objectForKey:@"storeItemPid"];
    [self getDataFromServer];
}

- (void)picDetailViewBack:(NSNotification*)notif
{
    [self.myScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)getDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        goodsDetailForm = [CZJGoodsDetailForm objectWithKeyValues:dict];
        
        //根据购买类型显示底部“加入购物车”与否（0表示是商品，显示“加入购物车”，1则表示服务，只显示“立即购买”）
        if (0 == [goodsDetailForm.goods.buyType floatValue])
        {
            self.addProductToWidth.constant = 100;
            self.immediatelyBuyWidth.constant = 100;
        }
        if (1 == [goodsDetailForm.goods.buyType floatValue])
        {
            self.addProductToWidth.constant = 0;
            self.immediatelyBuyWidth.constant = 160;
        }
        
        [self dealWithData];
        [self.detailTableView reloadData];
        tableViewContentSizeHeight = self.detailTableView.mj_contentH - self.detailTableView.mj_h;
        
        if (CZJDetailTypeGoods == self.detaiViewType)
        {
            [self getHotRecommendDataFromServer];
        }
        
        //图文详情页
        CZJPicDetailController *FController = [[CZJPicDetailController alloc]init];
        FController.detaiViewType = self.detaiViewType;
        CZJBuyNoticeController *SController = [[CZJBuyNoticeController alloc]init];
        SController.detaiViewType = self.detaiViewType;
        CZJAfterServiceController *TController = [[CZJAfterServiceController alloc]init];
        TController.detaiViewType = self.detaiViewType;
        CZJApplicableCarController *AController = [[CZJApplicableCarController alloc]init];
        AController.detaiViewType = self.detaiViewType;
        
        CZJPageControlView* webVie = [[CZJPageControlView alloc]initWithFrame:CGRectMake(0, (PJ_SCREEN_HEIGHT-50), PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-114)) andPageIndex:kPagePicDetail];
        
        [webVie setTitleArray:@[@"图文详情",@"购买须知",@"包装售后",@"适用车型"] andVCArray:@[FController,SController,TController,AController]];
        [self.myScrollView addSubview:webVie];
        
        [SVProgressHUD dismiss];
    };
    NSDictionary* param = @{@"storeItemPid":self.storeItemPid, @"promotionPrice":self.promotionPrice, @"promotionType":[NSString stringWithFormat:@"%ld",self.promotionType]};
    NSString* apiUrl;
    if (CZJDetailTypeGoods == _detaiViewType)
    {
        
        apiUrl = kCZJServerAPIGoodsDetail;
    }
    else if (CZJDetailTypeService == _detaiViewType)
    {
        apiUrl = kCZJServerAPIServiceDetail;
    }
    
    [CZJBaseDataInstance generalPost:param success:successBlock andServerAPI:apiUrl];
}

- (void)getHotRecommendDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSArray* dict = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
        _recommendServiceForms = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
        [self.detailTableView reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationFade];
    };
    
    [CZJBaseDataInstance loadDetailHotRecommendWithType:self.detaiViewType
                                             andStoreId:_storeInfo.storeId
                                                Success:successBlock
                                                   fail:^{}];
}

- (void)dealWithData
{
    _couponForms = goodsDetailForm.coupons;
    _storeInfo = goodsDetailForm.store;
    _evalutionInfo = goodsDetailForm.evals;
    _goodsDetail = goodsDetailForm.goods;
    [USER_DEFAULT setObject:_goodsDetail.storeItemPid forKey:kUserDefaultDetailStoreItemPid];
    [USER_DEFAULT setObject:_goodsDetail.itemCode forKey:kUserDefaultDetailItemCode];
    self.attentionBtn.selected = _goodsDetail.attentionFlag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + (goodsDetailForm == nil ? 0 : 5);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (4 == section)
    {
        return 3;
    }
    if (5 == section)
    {
        return 2;
    }
    if (CZJDetailTypeService == self.detaiViewType && 3 == section)
    {//服务详情界面去掉已选cell
        return 0;
    }
    if (2 == section && _couponForms.count <= 0)
    {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //依据不同的内容加载不同类型的Cell
    switch (indexPath.section) {
        case 0:
        {//图片展示
            CZJDetailPicShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailPicShowCell" forIndexPath:indexPath];
            if (_goodsDetail.imgs.count > 0 && !cell.isInit) {
                [cell someMethodNeedUse:indexPath DataModel:_goodsDetail.imgs];
                cell.delegate = self;
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 1:
        {//详情描述
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell" forIndexPath:indexPath];
            cell.miaoShaLabel.hidden = YES;
            cell.leftTimeLabel.hidden = YES;
            cell.goShopImage.hidden = !goodsDetailForm.goods.goHouseFlag;
//            [cell.goShopImage setImage:[UIImage imageNamed:@""]];
//            cell.miaoShaLabel.text = _serviceDetail.;
//            cell.leftTimeLabel;
            
            NSString* priceStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.originalPrice == nil ? @"": _goodsDetail.originalPrice];
            [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:priceStr]];
            
            NSString* currentStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.currentPrice == nil ? @"" :_goodsDetail.currentPrice];
            cell.currentPriceLabel.text = currentStr;
            CGSize labelSize = [CZJUtils calculateTitleSizeWithString:currentStr WithFont:BOLDSYSTEMFONT(22)];
            cell.labelLayoutConst.constant = labelSize.width + 5;
            
            cell.purchaseCountLabel.text = _goodsDetail.purchaseCount;
            
            cell.productNameLabel.text = _goodsDetail.itemName;
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:_goodsDetail.itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 45];
            
            cell.productNameLayoutHeight.constant = prolabelSize.height;
            
            if (_goodsDetail.skillFlag)
            {
                cell.miaoShaLabel.hidden = NO;
                cell.leftTimeLabel.hidden = NO;
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;

        case 2:
        {//领券信息
            CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
            if (cell && _couponForms.count > 0 && !cell.isInit)
            {
                [cell initWithCouponDatas:_couponForms];
            }
            return cell;
        }
            break;

        case 3:
        {//已选规格
            chooosedProductCell = [tableView dequeueReusableCellWithIdentifier:@"CZJChoosedProductCell" forIndexPath:indexPath];
            chooosedProductCell.indexPath = indexPath;
            chooosedProductCell.sku = _goodsDetail.sku;
            chooosedProductCell.storeItemPid = _goodsDetail.storeItemPid;
            chooosedProductCell.productType.text = _goodsDetail.itemSku;
            chooosedProductCell.counterKey = _goodsDetail.counterKey;
            [chooosedProductCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return chooosedProductCell;
        }
            break;
            
        case 4:
        {//评论数据
            if (0 == indexPath.row) {
                CZJEvalutionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionHeaderCell" forIndexPath:indexPath];

                if (_evalutionInfo) {
                    cell.goodRateLabel.text = _evalutionInfo.goodRate;
                    cell.personCountLabel.text = _evalutionInfo.evalCount;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
                if (_evalutionInfo.evalList.count > 0)
                {
                    CZJEvalutionsForm* evalutionForm  = (CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1];
                    cell.evalWriter.text = evalutionForm.evalName;
                    cell.evalTime.text = evalutionForm.evalTime;
                    cell.evalContent.text = evalutionForm.evalDesc;
                    [cell.addtionnalImage sd_setImageWithURL:[NSURL URLWithString:evalutionForm.imgs[0]]
                                            placeholderImage:DefaultPlaceHolderImage];
                    [cell setStar:[evalutionForm.evalStar intValue]];
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (2 == indexPath.row)
            {
                CZJEvalutionFooterCell* cell = (CZJEvalutionFooterCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell"];
                [cell setVisibleView:kLookAllEvalView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
        case 5:
        {//门店信息介绍
            if (0 == indexPath.row)
            {
                CZJStoreInfoHeaerCell *cell = (CZJStoreInfoHeaerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoHeaerCell"  forIndexPath:indexPath];
                if (_storeInfo)
                {
                    [cell.storeImage sd_setImageWithURL:[NSURL URLWithString:_storeInfo.logo]
                                            placeholderImage:DefaultPlaceHolderImage];
                    cell.storeName.text = _storeInfo.storeName;
                    cell.storeAddr.text = _storeInfo.storeAddr;
                    cell.storeAddrLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.storeNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.attentionStore.selected = _storeInfo.attentionFlag;
                    cell.delegate = self;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJStoreInfoCell *cell = (CZJStoreInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoCell" forIndexPath:indexPath];
                if (_storeInfo)
                {
                    cell.attentionNumber.text = _storeInfo.attentionCount;
                    cell.goodsNumber.text = _storeInfo.goodsCount;
                    cell.serviceNumber.text = _storeInfo.serviceCount;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            
        }
            break;
            
        case 6:
        {//热门推荐
           
            CZJHotRecommendCell *cell = (CZJHotRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJHotRecommendCell" forIndexPath:indexPath];
            if (!cell.isInit && _recommendServiceForms.count > 0) {
                [cell setHotRecommendDatas:_recommendServiceForms];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        case 7:
        {//热门推荐
            CZJOrderTypeExpandCell *cell = (CZJOrderTypeExpandCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeExpandCell" forIndexPath:indexPath];
            [cell setCellType:CZJCellTypeDetail];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
            
        default:
            return nil;
            break;
    }
    return nil;
    
}


#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 375;
            break;
        case 1:
        {
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell"];
            NSString* itemName = _goodsDetail.itemName;
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 45];
            if (_goodsDetail.skillFlag)
            {
                return 88 + prolabelSize.height;
                
            }
            else
            {
                return 65 + prolabelSize.height;
            }
        }
            break;
        case 2:
            return 46;
            break;
        case 3:
            return 46;
            break;
        case 4:
            if (0 == indexPath.row) {
                return 46;
            }
            if (1 == indexPath.row) {
                //这里是动态改变的，暂时设一个固定值
                return 160;
            }
            if (2 == indexPath.row)
            {
                return 64;
            }
            break;
        case 5:
            if (0 == indexPath.row)
            {
                return 81;
            }
            if (1 == indexPath.row)
            {
                return 131;
            }
            break;
        case 6:
            return 404;
            break;
            
        case 7:
            return 46;
            break;
            
        default:
            return 46;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section ||
        1 == section ||
        2 == section ||
        3 == section)
    {
        return 0;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.section)
    {
        self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        [CZJUtils showMyWindowOnTarget:self withMyVC:receiveCouponsController];
        
        __weak typeof(self) weak = self;
        [receiveCouponsController setCancleBarItemHandle:^{
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
    if (3 == indexPath.section)
    {
        self.popWindowInitialRect =  CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.popWindowDestineRect = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        CZJChooseProductTypeController *chooseProductTypeController = [[CZJChooseProductTypeController alloc] init];
        chooseProductTypeController.counterKey = chooosedProductCell.counterKey;
        chooseProductTypeController.storeItemPid = chooosedProductCell.storeItemPid;
        chooseProductTypeController.currentSku = chooosedProductCell.sku;
        if (chooseProductTypeController.counterKey &&
            chooseProductTypeController.storeItemPid)
        {
            [chooseProductTypeController getSKUDataFromServer];
        }
        [CZJUtils showMyWindowOnTarget:self withMyVC:chooseProductTypeController];
    }
    if (4 == indexPath.section && 2 ==indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueToUserEvalution" sender:self];
    }
}


#pragma mark- CZJNaviBarViewDelegate(导航栏三个按钮的代理回调)
- (void)clickEventCallBack:(id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = @[@{@"消息" : @"prodetail_icon_msg"},
                              @{@"首页":@"prodetail_icon_home"},
                              @{@"分享" :@"prodetail_icon_share"}];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 150);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr  andType:CZJNIDropDownTypeNormal];
                dropDown.delegate = self;
            }
        }
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
        }];
    }
    complete();
}


#pragma mark- NIDropDownDelegate(更多按钮弹出框回调)
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
    }
    if ([btnStr isEqualToString:@"首页"])
    {
    }
    if ([btnStr isEqualToString:@"分享"])
    {
    }
}


#pragma mark- CZJStoreInfoHeaerCellDelegate(关注店铺回调)
- (void)clickAttentionStore:(id)sender
{
    NSDictionary* params = @{@"storeId" : _storeInfo.storeId};
    if (!_storeInfo.attentionFlag) {
        [CZJBaseDataInstance attentionStore:params success:^(id json) {
            _storeInfo.attentionFlag = !_storeInfo.attentionFlag;
            _storeInfo.attentionCount = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            [self.detailTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
            [CZJUtils tipWithText:@"关注成功" andView:self.view];
        }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionStore:params success:^(id json) {
            _storeInfo.attentionFlag = !_storeInfo.attentionFlag;
            _storeInfo.attentionCount = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            [self.detailTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
            [CZJUtils tipWithText:@"取消关注" andView:self.view];
        }];
    }
}


#pragma mark- ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
//    DLog(@"%f",contentOffsetY);
    if (kTagTableView == scrollView.tag && contentOffsetY <=0)
    {
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(0)];
    }
    else if (kTagTableView == scrollView.tag && contentOffsetY > 0)
    {
        float alphaValue = contentOffsetY / 300;
        if (alphaValue > 1)
        {
            alphaValue = 1;
        }
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(alphaValue)];
    }
    
    //去掉tableview中section的headerview粘性
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
    if (scrollView.tag ==kTagTableView && contentOffsetY > tableViewContentSizeHeight) {
        isButtom = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    float contentOffsetY = [scrollView contentOffset].y;

    if (isButtom && kTagTableView == scrollView.tag && contentOffsetY >= tableViewContentSizeHeight + 30)
    {
        [self.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-114)) animated:true];
        isButtom = NO;
    }
//    DLog(@"velocity.y:%f, offset:%f",velocity.y, targetContentOffset->y);
}


#pragma mark- CZJImageTouchViewDelegate(顶部图片预览回调)
- (void)showDetailInfoWithIndex:(NSInteger)index
{
    WyzAlbumViewController *wyzAlbumVC = [[WyzAlbumViewController alloc]init];
    wyzAlbumVC.currentIndex =index;//这个参数表示当前图片的index，默认是0
    //用url
    wyzAlbumVC.imgArr = _goodsDetail.imgs;
    //进入动画
    [self presentViewController:wyzAlbumVC animated:YES completion:^
    {
    }];
}


#pragma mark- Action
- (IBAction)immediatelyBuyAction:(id)sender
{
    NSDictionary* itemDict = @{@"itemCode" : goodsDetailForm.goods.itemCode,
                               @"storeItemPid" : goodsDetailForm.goods.storeItemPid,
                               @"itemImg" : goodsDetailForm.goods.itemImg,
                               @"itemName" : goodsDetailForm.goods.itemName,
                               @"itemSku" : goodsDetailForm.goods.itemSku,
                               @"itemType" : goodsDetailForm.goods.itemType,
                               @"itemCount" : @"1",
                               };

    NSArray* itemAry = @[itemDict];
    NSDictionary* storeDict = @{@"items" :itemAry,
                                @"storeName" : goodsDetailForm.store.storeName,
                                @"storeId" :goodsDetailForm.store.storeId,
                                @"companyId" :goodsDetailForm.store.companyId,
                                @"selfFlag" : goodsDetailForm.goods.selfFlag ? @"true" : @"false"
                                };
    [_settleOrderAry addObject:storeDict];
    CZJCommitOrderController* settleOrder = (CZJCommitOrderController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"SBIDCommitSettle"];
    settleOrder.settleParamsAry = _settleOrderAry;
    [self.navigationController pushViewController:settleOrder animated:true];
    [CZJUtils tipWithText:@"结算成功" andView:nil];
}

- (IBAction)addProductToShoppingCartAction:(id)sender
{
    NSDictionary* pramas = @{
                             @"companyId" : _goodsDetail.companyId ? _goodsDetail.companyId : @"",
                             @"storeId" : _goodsDetail.storeId,
                             @"storeItemPid" : _goodsDetail.storeItemPid,
                             @"itemType" : _goodsDetail.itemType,
                             @"itemCode" : _goodsDetail.itemCode,
                             @"itemName" : _goodsDetail.itemName,
                             @"itemCount" : @1,
                             @"currentPrice" : _goodsDetail.currentPrice,
                             @"itemImg" : _goodsDetail.itemImg,
                             @"itemSku" : _goodsDetail.itemSku,
                             @"counterKey" : _goodsDetail.counterKey
                             };
    
    [CZJBaseDataInstance addProductToShoppingCart:pramas Success:^{
        CGRect addBtnRect = [self.view convertRect:_addProductToShoppingCartBtn.frame fromView:_shoppingCartView];
        CGRect shoppingCartBtnRect = [self.view convertRect:self.naviBarView.btnShop.frame fromView:self.naviBarView];
        
        UIImageView* itemImage = [[UIImageView alloc] initWithImage:IMAGENAMED(@"prodetail_btn_shop")];
        itemImage.frame = CGRectMake(addBtnRect.origin.x + (addBtnRect.size.width - 50)/2, addBtnRect.origin.y + (addBtnRect.size.height - 40)/2, 40, 40);
        [self.view addSubview:itemImage];
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            itemImage.size  = CGSizeMake(20, 20);
            CGPoint desPt = CGPointMake(shoppingCartBtnRect.origin.x + shoppingCartBtnRect.size.width*0.5,shoppingCartBtnRect.origin.y + shoppingCartBtnRect.size.height*0.5);
            [itemImage setPosition:desPt atAnchorPoint:CGPointMake(0.5, 0.5)];
            itemImage.alpha = 0.8;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    itemImage.alpha = 0;
                    itemImage.transform = CGAffineTransformMakeScale(3, 3);
                } completion:^(BOOL finished) {
                    [itemImage removeFromSuperview];
                }];
                [self.naviBarView refreshShopBadgeLabel];
            }
        }];
        
    } fail:^{
        
    }];
    
}


- (IBAction)attentionAction:(id)sender
{
    NSDictionary* params = @{@"storeItemPid" : _goodsDetail.storeItemPid,
                             @"itemType" : _goodsDetail.itemType};
    if (!self.attentionBtn.selected)
    {
        [CZJBaseDataInstance attentionGoods:params success:^(id json)
        {
            _goodsDetail.attentionFlag = !_goodsDetail.attentionFlag;
            self.attentionBtn.selected = !self.attentionBtn.selected;
            [CZJUtils tipWithText:@"关注成功" andView:self.view];
        }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionGoods:params success:^(id json)
        {
            _goodsDetail.attentionFlag = !_goodsDetail.attentionFlag;
            self.attentionBtn.selected = !self.attentionBtn.selected;
            [CZJUtils tipWithText:@"取消关注" andView:self.view];
        }];
    }
}

- (IBAction)contactServiceAction:(id)sender
{
    
}

- (IBAction)storeAction:(id)sender
{
    
}

@end
