//
//  CZJDetailViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "CZJDetailViewController.h"
#import "NIDropDown.h"
#import "CZJBaseDataManager.h"
#import "CZJPageControlView.h"
#import "CZJDetailDescCell.h"
#import "CZJDetailPicShowCell.h"
#import "CZJChoosedProductCell.h"
#import "CZJCouponsCell.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJEvalutionHeaderCell.h"
#import "CZJStoreInfoHeaerCell.h"
#import "CZJDetailReturnableAnyWayCell.h"
#import "CZJStoreInfoCell.h"
#import "CZJHotRecommendCell.h"
#import "CZJOrderTypeExpandCell.h"
#import "WyzAlbumViewController.h"
#import "CZJChooseProductTypeController.h"
#import "CZJPicDetailBaseController.h"
#import "CZJGoodsDetailForm.h"
#import "CZJStoreForm.h"
#import "CZJCommitOrderController.h"
#import "CZJPromotionController.h"
#import "CZJStoreDetailController.h"
#import "CZJUserEvalutionController.h"
#import "CZJAddedEvalutionCell.h"
#import "CZJReceiveCouponsController.h"
#import "CZJGeneralCell.h"
#import "CZJMiaoShaControlHeaderCell.h"
#import "ShareMessage.h"
#import "CZJMyInfoOrderListController.h"
#import "CZJMyInfoAttentionController.h"
#import "CZJMyInfoRecordController.h"
#import "CZJMyMessageCenterController.h"
#import "CZJChatViewController.h"
#import "AppDelegate.h"

#define kTagScrollView  1002
#define kTagTableView   1001
#define kTagOverLay     9999
#define kTagRenderImage 9998


@interface UIImage (Blur)
- (UIImage*)boxblurImageWithBlur:(CGFloat)blur;
@end

@interface CZJDetailViewController ()
<
NIDropDownDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate,
CZJStoreInfoHeaerCellDelegate,
CZJChooseProductTypeDelegate
>
{
    NIDropDown *dropDown;
    BOOL isScorllUp;
    BOOL isLoadDataFromServer;
    
    CGFloat tableViewContentSizeHeight;
    __block BOOL isButtom;
    
    //当前页面数据
    CZJGoodsDetailForm* goodsDetailForm;            //详情界面总数据
    CZJStoreInfoForm* _storeInfo;                   //服务门店信息
    CZJDetailEvalInfo* _evalutionInfo;              //服务评价简介
    CZJGoodsDetail* _goodsDetail;                   //商品信息
    NSArray* _couponForms;                          //领券列表
    NSArray* _recommendServiceForms;                //推荐服务列表
    
    CZJChoosedProductCell* chooosedProductCell;     //已选商品cell，定义成成员变量是为了方便传值
    CZJMiaoShaControlHeaderCell* miaoShaCell;       //秒杀栏
    NSInteger _timestamp;                           //秒杀倒计时
    NSTimer* timer;                                 //秒杀定时器
    
    UIView *_backgroundView;
    
    NSMutableArray* _settleOrderAry;
    NSInteger buyCount;                             //当前商品已选规格个数
}
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIView *borderLineView;
//@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *shoppingCartView;
@property (weak, nonatomic) IBOutlet UIButton *addProductToShoppingCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyImeditelyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderLineLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProductToWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *immediatelyBuyWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goinStoreViewWidth;
@property (weak, nonatomic) IBOutlet UIView *serviceView;

@property (strong, nonatomic) UITableView* detailTableView;
@property (weak, nonatomic) IBOutlet UIView *storeView;

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
    [CZJUtils performBlock:^{
        [self getDataFromServer];
    } afterDelay:0.3];
    [self registNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.naviBarView refreshShopBadgeLabel];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
    [CZJUtils performBlock:^{
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
            webVie.backgroundColor = CZJNAVIBARBGCOLOR;
            if (_detaiViewType == CZJDetailTypeService)
            {
                [webVie setTitleArray:@[@"图文详情",@"购买须知",@"适用车型"] andVCArray:@[FController,SController,AController]];
            }
            else
            {
                [webVie setTitleArray:@[@"图文详情",@"规格参数",@"包装售后",@"适用车型"] andVCArray:@[FController,SController,TController,AController]];
            }
            [self.myScrollView addSubview:webVie];
    } afterDelay:0.5];

}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        [self removeNotification];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
}


- (void)initDatas
{
    _recommendServiceForms = [NSArray array];
    _couponForms = [NSArray array];
    _settleOrderAry = [NSMutableArray array];
    buyCount = 1;
}

- (void)initViews
{
    [self.naviBarView.btnBack setBackgroundColor:RGBA(230, 230, 230, 0.8)];
    [self.naviBarView.btnMore setBackgroundColor:RGBA(230, 230, 230, 0.8)];
//    [self.naviBarView.btnShop setBackgroundColor:RGBA(230, 230, 230, 0.8)];
    self.addProductToWidth.constant = 0;
    self.immediatelyBuyWidth.constant = 0;
    
    self.borderLineLayoutHeight.constant = 0.5;
    self.borderLineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02") forState:UIControlStateNormal];
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02_sel") forState:UIControlStateSelected];
    
    //背景触摸层
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    [CZJAppdelegate.window addSubview:_backgroundView];
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    UISwipeGestureRecognizer* leftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer* rightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer* downGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    UISwipeGestureRecognizer* upGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [upGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [_backgroundView addGestureRecognizer:gesture];
    [_backgroundView addGestureRecognizer:downGesture];
    [_backgroundView addGestureRecognizer:upGesture];
    [_backgroundView addGestureRecognizer:leftGesture];
    [_backgroundView addGestureRecognizer:rightGesture];
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
                          @"CZJOrderTypeExpandCell",
                          @"CZJAddedEvalutionCell",
                          @"CZJDetailReturnableAnyWayCell"
                          ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.detailTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    _detailTableView.tag = kTagTableView;
    self.detailTableView.tableFooterView = [[UIView alloc] init];
    [self.myScrollView addSubview:_detailTableView];
    [self.detailTableView reloadData];
    self.shoppingCartView.hidden = YES;
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDetailData:) name:kCZJNotifiRefreshDetailView  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(picDetailViewBack:) name:kCZJNotifiPicDetailBack object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jumpToOrderListWithPayFailed:) name:kCZJNotifiJumpToOrderList object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiRefreshDetailView object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiPicDetailBack object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiJumpToOrderList object:nil];
}

- (void)reloadDetailData:(NSNotification*)notif
{
    self.storeItemPid = [notif.userInfo objectForKey:@"storeItemPid"];
    buyCount = [[notif.userInfo objectForKey:@"buycount"] integerValue];
    [self getDataFromServer];
}

- (void)picDetailViewBack:(NSNotification*)notif
{
    [self.myScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)jumpToOrderListWithPayFailed:(NSNotification*)notif
{
    CZJMyInfoOrderListController* orderListVC = (CZJMyInfoOrderListController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDMyOrderList];
    orderListVC.orderListTypeIndex = 1;
    [self.navigationController pushViewController:orderListVC animated:YES];
}

- (void)getDataFromServer
{
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
    
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CZJSuccessBlock successBlock = ^(id json)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        goodsDetailForm = [CZJGoodsDetailForm objectWithKeyValues:dict];
        DLog(@"goodsDetailForm:%@",[goodsDetailForm.keyValues description]);
        //根据购买类型显示底部“加入购物车”与否（0表示是商品，显示“加入购物车”，1则表示服务，只显示“立即购买”）
        if (0 == [goodsDetailForm.goods.buyType floatValue])
        {
//            weakSelf.addProductToWidth.constant = (iPhone4 || iPhone5) ? 80 : 100;
//            weakSelf.immediatelyBuyWidth.constant = (iPhone4 || iPhone5) ? 80 : 100;;
        }
        if (1 == [goodsDetailForm.goods.buyType floatValue])
        {
//            weakSelf.addProductToWidth.constant = 0;
//            weakSelf.immediatelyBuyWidth.constant = (iPhone4 || iPhone5) ? 130 : 160;;
        }
//        _storeView.hidden = goodsDetailForm.goods.selfFlag;
        
        [weakSelf dealWithData];
        [weakSelf.detailTableView reloadData];
        weakSelf.detailTableView.hidden = NO;
        weakSelf.shoppingCartView.hidden = NO;
        //获取热门商品或服务
        [weakSelf getHotRecommendDataFromServer];
        
    };
    

    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJBaseDataInstance generalPost:param success:successBlock  fail:^{
        weakSelf.detailTableView.hidden = YES;
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weakSelf.view withReloadHandle:^{
            [weakSelf getDataFromServer];
        }];
    } andServerAPI:apiUrl];
}

- (void)getHotRecommendDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSArray* dict = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
//        DLog(@"hotrecommend:%@",[dict description]);
        _recommendServiceForms = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
        [self.detailTableView reloadData];
        /*为什么不能用 [self.detailTableView reloadSections:[NSIndexSet  indexSetWithIndex:*withRowAnimation:UITableViewRowAnimationNone];，
        *是因为要重新计算TableView的ContentSize
        */
        
        //推荐商品获取完成后再计算TableView的contentSize
        DLog(@"contentSizeHeight:%f, frameHeight:%f",self.detailTableView.mj_contentH,self.detailTableView.mj_h)
        tableViewContentSizeHeight = self.detailTableView.mj_contentH - self.detailTableView.mj_h;
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
    _goodsDetail.sku.storeItemPid = _goodsDetail.storeItemPid;
    [USER_DEFAULT setValue:_goodsDetail.storeItemPid forKey:kUserDefaultDetailStoreItemPid];
    [USER_DEFAULT setValue:_goodsDetail.itemCode forKey:kUserDefaultDetailItemCode];
    self.attentionBtn.selected = _goodsDetail.attentionFlag;
    isLoadDataFromServer = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + (goodsDetailForm == nil ? 0 : 6);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (2 == section && _couponForms.count <= 0)
    {
        return 0;
    }
    if (4 == section)
    {
        return ((CZJDetailTypeGoods == _detaiViewType && CZJGoodsPromotionTypeGeneral == _promotionType) ? 2 : 0);
    }
    if (3 == section)
    {
        return goodsDetailForm.promotions.count > 0 ? 1 : 0;
    }
    if (5 == section)
    {
        return _evalutionInfo.evalList.count > 0 ? _evalutionInfo.evalList.count + 2 : 0;
    }
    if (6 == section)
    {
        
        return _goodsDetail.selfFlag ? 0 : 2;
    }
    if (CZJDetailTypeService == self.detaiViewType && 3 == section)
    {//服务详情界面去掉已选cell
        return 0;
    }
    if (7 == section)
    {
        return _recommendServiceForms.count > 0 ? 1 : 0;
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
            if (_goodsDetail.imgs.count > 0 && isLoadDataFromServer)
            {
                isLoadDataFromServer = NO;
                [cell someMethodNeedUse:indexPath DataModel:_goodsDetail.imgs];
                cell.delegate = self;
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
            break;
            
        case 1:
        {//详情描述
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell" forIndexPath:indexPath];
            //商品名称
            cell.productNameLabel.text = _goodsDetail.itemName;
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:_goodsDetail.itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 40];
            cell.productNameLayoutHeight.constant = (prolabelSize.height > 20) ? 40 : 20;
            
            //商品当前价格
            NSString* currentStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.currentPrice == nil ? @"" :_goodsDetail.currentPrice];
            cell.currentPriceLabel.text = currentStr;
            CGSize labelSize = [CZJUtils calculateTitleSizeWithString:currentStr WithFont:BOLDSYSTEMFONT(22)];
            cell.labelLayoutConst.constant = labelSize.width + 5;
            cell.currentPriceLabel.keyWord = @"￥";
            
            //是否到店标示
            cell.goShopImage.hidden = !goodsDetailForm.goods.goHouseFlag;
            
            //如果是秒杀商品有原价
            if (CZJGoodsPromotionTypeMiaoSha == _promotionType)
            {
                //商品原价
                NSString* originStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.originalPrice == nil ? @"" :_goodsDetail.originalPrice];
                [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:originStr]];
                CGSize originSize = [CZJUtils calculateTitleSizeWithString:originStr WithFont:SYSTEMFONT(14)];
                cell.originPriceWidth.constant = originSize.width + 5;
                
                //秒杀栏
                miaoShaCell = [CZJUtils getXibViewByName:@"CZJMiaoShaControlHeaderCell"];
                miaoShaCell.miaoshaIconLeading.constant = 20;
                miaoShaCell.miaoShaTypeLabel.hidden = YES;
                miaoShaCell.frame = CGRectMake(0, 50 + cell.productNameLayoutHeight.constant, PJ_SCREEN_WIDTH, 35);
                [cell addSubview:miaoShaCell];
                [self setTimestamp:_miaoShaInterval];
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
            
        case 4:
        {//已选规格
            if (0 == indexPath.row)
            {
                chooosedProductCell = [tableView dequeueReusableCellWithIdentifier:@"CZJChoosedProductCell" forIndexPath:indexPath];
                chooosedProductCell.indexPath = indexPath;
                
                chooosedProductCell.goodsDetail = _goodsDetail;
                chooosedProductCell.storeItemPid = _goodsDetail.storeItemPid;
                chooosedProductCell.productType.text = [NSString stringWithFormat:@"%@ %ld个",[_goodsDetail.sku.skuValues isEqualToString:@"null"] ? @"" : _goodsDetail.sku.skuValues,buyCount];
                chooosedProductCell.counterKey = _goodsDetail.counterKey;
                [chooosedProductCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return chooosedProductCell;
            }
            if (1 == indexPath.row)
            {
                CZJDetailReturnableAnyWayCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailReturnableAnyWayCell" forIndexPath:indexPath];
                return cell;
            }
        }
            break;
            
        case 3:
        {//促销
            CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
            cell.arrowImg.hidden = YES;
            cell.couponNameLabel.text = @"促销";
            cell.couponScrollView.clipsToBounds = NO;
            if (goodsDetailForm.promotions.count > 0)
            {
                NSInteger range = goodsDetailForm.promotions.count >= 2 ? 2 : goodsDetailForm.promotions.count;
                for (int i = 0 ; i < range; i++)
                {
                    CZJPromotionItemForm* promotionItem = (CZJPromotionItemForm*)goodsDetailForm.promotions[i];
                    CZJGeneralCell* promotionItemCell = [CZJUtils getXibViewByName:@"CZJGeneralCell"];
                    promotionItemCell.backgroundColor = CLEARCOLOR;
                    NSString* imageName;
                    if ([promotionItem.type integerValue] == 0)
                    {
                        imageName = @"label_icon_jian";
                    }
                    else
                    {
                        imageName = @"label_icon_zengpin";
                    }
                    promotionItemCell.arrowTrailing.constant = 20;
                    promotionItemCell.imageViewHeight.constant = 15;
                    promotionItemCell.imageViewWidth.constant = 30;
                    [promotionItemCell.headImgView setImage:IMAGENAMED(imageName)];
                    promotionItemCell.nameLabelWidth.constant = PJ_SCREEN_WIDTH - 130;
                    promotionItemCell.nameLabel.text = promotionItem.desc;
                    promotionItemCell.nameLabel.font = SYSTEMFONT(13);
                    promotionItemCell.nameLabel.textColor = RGB(109, 109, 109);
                    CGRect cellRect = CGRectMake(-15, 15 + i * 30, PJ_SCREEN_WIDTH - 40, 15);
                    promotionItemCell.frame = cellRect;
                    
                    UIButton* tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [tapButton addTarget:self action:@selector(tapPromotionCell:) forControlEvents:UIControlEventTouchUpInside];
                    tapButton.frame = CGRectMake(0, -5, promotionItemCell.frame.size.width, promotionItemCell.frame.size.height + 10);
                    tapButton.tag = [promotionItem.type integerValue];
                    [promotionItemCell addSubview:tapButton];
                    
                    [cell.couponScrollView addSubview:promotionItemCell];
                }
            }
            return cell;
        }
            break;
            
        case 5:
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
            else if (_evalutionInfo.evalList.count + 1 > indexPath.row)
            {
                CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
                if (_evalutionInfo.evalList.count > 0)
                {
                    CZJEvaluateForm* evalutionForm  = (CZJEvaluateForm*)_evalutionInfo.evalList[indexPath.row - 1];
                    cell.evalWriter.text = evalutionForm.name;
                    cell.evalTime.text = evalutionForm.evalTime;
                    
                    
                    cell.evalContent.text = evalutionForm.message;
                    CGSize contenSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                    cell.evalContentLayoutHeight.constant = contenSize.height;
                    
                    for (int i = 0; i < evalutionForm.evalImgs .count; i++)
                    {
                        UIImageView* evaluateImage = [[UIImageView alloc]init];
                        [evaluateImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",evalutionForm.evalImgs[i],SUOLUE_PIC_200]] placeholderImage:DefaultPlaceHolderSquare];
                        CGRect iamgeRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 10) size:CGSizeMake(78, 78) index:i divide:Divide];
                        evaluateImage.frame = iamgeRect;
                        [cell.picView addSubview:evaluateImage];
                    }
                    [cell setStar:[evalutionForm.score intValue]];
                    
                    
                    if ([evalutionForm.added boolValue])
                    {
                        CGSize contentSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                        NSInteger row = evalutionForm.evalImgs.count / Divide + 1;
                        NSInteger cellHeight = 60 + (contentSize.height > 20 ? contentSize.height : 20) + row * 88;
                        
                        
                        CZJAddedEvalutionCell* addedCell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddedEvalutionCell" forIndexPath:indexPath];
                        addedCell.addedTimeLabel.text = evalutionForm.addedEval.evalTime;
                        addedCell.addedContentLabel.text = evalutionForm.addedEval.message;
                        float strHeight = [CZJUtils calculateStringSizeWithString:evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
                        addedCell.contentLabelHeight.constant = strHeight + 5;
                        
                        for (int i = 0; i < evalutionForm.addedEval.evalImgs.count; i++)
                        {
                            NSString* url = evalutionForm.addedEval.evalImgs[i];
                            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(70, 70) index:i divide:Divide];
                            UIImageView* imageView = [[UIImageView alloc]initWithFrame:imageFrame];
                            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url,SUOLUE_PIC_200]] placeholderImage:DefaultPlaceHolderSquare];
                            [addedCell.picView addSubview:imageView];
                        }
                        
                        float picViewHeight = 0;
                        if (evalutionForm.addedEval.evalImgs.count != 0)
                        {
                            picViewHeight = 70*(evalutionForm.addedEval.evalImgs.count / Divide + 1);
                        }
                        NSInteger addedHeight = 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
                        
                        CGRect addcellFrame = CGRectMake(0, cellHeight, PJ_SCREEN_WIDTH, addedHeight);
                        addedCell.frame = addcellFrame;
                        [cell addSubview:addedCell];
                    }
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else
            {
                CZJEvalutionFooterCell* cell = (CZJEvalutionFooterCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell"];
                [cell setVisibleView:kLookAllEvalView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
        case 6:
        {//门店信息介绍
            if (0 == indexPath.row)
            {
                CZJStoreInfoHeaerCell *cell = (CZJStoreInfoHeaerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoHeaerCell"  forIndexPath:indexPath];
                if (_storeInfo)
                {
                    [cell.storeImage sd_setImageWithURL:[NSURL URLWithString:_storeInfo.logo]
                                       placeholderImage:DefaultPlaceHolderSquare];
                    cell.storeName.text = _storeInfo.storeName;
                    cell.storeAddr.text = _storeInfo.storeAddr;
                    cell.storeAddrLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.storeNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.attentionStore.selected = _storeInfo.attentionFlag;
                    if (_storeInfo.attentionFlag)
                    {
                        [cell.attentionStore setTitle:@"已关注" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [cell.attentionStore setTitle:@"关注门店" forState:UIControlStateNormal];
                    }
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
                [cell.intoStoreButton addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
            
        case 7:
        {//热门推荐
            CZJHotRecommendCell *cell = (CZJHotRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJHotRecommendCell" forIndexPath:indexPath];
            
            if (!cell.isInit && _recommendServiceForms.count > 0) {
                __weak typeof(self) weak = self;
                [cell setHotRecommendDatas:_recommendServiceForms andButtonHandler:^(id data) {
                    CZJStoreServiceForm* hotRecommendGood = (CZJStoreServiceForm*)data;
                    CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
                    detailVC.storeItemPid = hotRecommendGood.storeItemPid;
                    detailVC.promotionType = CZJGoodsPromotionTypeGeneral;
                    detailVC.promotionPrice = @"";
                    [weak.navigationController pushViewController:detailVC animated:YES];
                }];
            }
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        case 8:
        {//上拉查看图文详情
            CZJOrderTypeExpandCell *cell = (CZJOrderTypeExpandCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeExpandCell" forIndexPath:indexPath];
            [cell setCellType:CZJCellTypeDetail];
            __weak typeof(self) weak = self;
            cell.buttonClick = ^(id data)
            {
                [weak.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-114)) animated:true];
                isButtom = NO;
            };
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
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 40];
            float itemNameHeight = prolabelSize.height > 20 ? 40 : 20;
            float miaoshaHeight = ((CZJGoodsPromotionTypeMiaoSha == _promotionType) ? 35 : 0);
            return 50 + itemNameHeight + miaoshaHeight + 5;
        }
            break;
        case 2:
            return 55;
            break;
        case 4:
            if (0 == indexPath.row)
            {
                return 46;
            }
            if (1 == indexPath.row)
            {
                return 35;
            }
            break;
        case 3:
            if (goodsDetailForm.promotions.count >= 2)
            {
                return 75;
            }
            return 45;
            break;
        case 5:
            if (0 == indexPath.row) {
                return 46;
            }
            else if (_evalutionInfo.evalList.count + 1 > indexPath.row)
            {
                CZJEvaluateForm* evalutionForm  = (CZJEvaluateForm*)_evalutionInfo.evalList[indexPath.row - 1];
                CGSize contenSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                NSInteger row = evalutionForm.evalImgs.count > 0 ? 1 : 0;
                NSInteger cellHeight = 60 + (contenSize.height > 20 ? contenSize.height : 20) + row * 88;
                
                NSInteger addedHeight = 0;
                if ([evalutionForm.added boolValue])
                {
                    float strHeight = [CZJUtils calculateStringSizeWithString:evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40].height;
                    float picViewHeight = 0;
                    if (evalutionForm.addedEval.evalImgs.count != 0)
                    {
                        picViewHeight = 70;
                    }
                    addedHeight = 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
                }
                return cellHeight + addedHeight;
                
            }
            else
            {
                return 64;
            }
            break;
        case 6:
            if (0 == indexPath.row)
            {
                return 81;
            }
            if (1 == indexPath.row)
            {
                return 131;
            }
            break;
        case 7:
            return (iPhone4 || iPhone5) ? 400 : 400;
            break;
            
        case 8:
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
        3 == section ||
        4 == section ||
        (5 == section && _evalutionInfo.evalList.count == 0) ||
        (6 == section && _goodsDetail.selfFlag))
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.section )
    {
        __weak typeof(self) weak = self;
        self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        receiveCouponsController.storeId = _storeInfo.storeId;
        receiveCouponsController.popWindowInitialRect = self.popWindowInitialRect;

        
        //当前视图控制器的upView上添加手势监测
        //初始化upView
        self.upView = [[UIView alloc] initWithFrame:self.view.bounds];
        //添加背景层点击隐藏手势、向右侧滑隐藏手势、向下滑隐藏手势和弹出页向右侧滑隐藏手势
        [self.upView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        [self.upView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        [receiveCouponsController.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        UISwipeGestureRecognizer* downGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)];
        [downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.upView addGestureRecognizer:downGesture];
        //将upView添加到当前View上
        [self.view addSubview:self.upView];
        
        //动画效果
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * ss = [[UIImageView alloc] initWithImage:[image boxblurImageWithBlur:0.1]];
        ss.tag = kTagRenderImage;
        [self.upView addSubview:ss];
        self.upView.backgroundColor = BLACKCOLOR;
        DLog(@"基图:%p, 覆盖图:%p, renderImage:%p",self.view,self.upView,ss);
        
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        [UIView animateWithDuration:0.5 animations:^{
            ss.alpha = 0.7;
        }];
        
        //初始化一个自定义弹窗视图
        UIWindow *myWindow = [[UIWindow alloc] initWithFrame:self.popWindowInitialRect];
        self.window = myWindow;
        myWindow.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:self.windowAlpha];
        myWindow.windowLevel = UIWindowLevelNormal;
        myWindow.hidden = NO;
        myWindow.rootViewController = receiveCouponsController;
        [myWindow makeKeyAndVisible];
        
        
        //动画出现弹窗视图
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.windowAlpha = 1.0f;
            weakSelf.window.frame =  weakSelf.popWindowDestineRect;
            weakSelf.upView.alpha = 1.0;
        } completion:nil];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        
        [receiveCouponsController setCancleBarItemHandle:^{
            [weak dismissWithAnimation];
        }];
        return;
    }
    if (4 == indexPath.section && 0 == indexPath.row)
    {
        __weak typeof(self) weak = self;
        self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        CZJChooseProductTypeController *chooseProductTypeController = [[CZJChooseProductTypeController alloc] init];
        chooseProductTypeController.goodsDetail = chooosedProductCell.goodsDetail;
        chooseProductTypeController.buycount = buyCount;
        chooseProductTypeController.delegate = self;
        chooseProductTypeController.popWindowInitialRect = self.popWindowInitialRect;
        
        
        //当前视图控制器的upView上添加手势监测
        //初始化upView
        self.upView = [[UIView alloc] initWithFrame:self.view.bounds];
        //添加背景层点击隐藏手势、向右侧滑隐藏手势、向下滑隐藏手势和弹出页向右侧滑隐藏手势
        [self.upView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        [self.upView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        [chooseProductTypeController.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)]];
        UISwipeGestureRecognizer* downGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithAnimation)];
        [downGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.upView addGestureRecognizer:downGesture];
        //将upView添加到当前View上
        [self.view addSubview:self.upView];
        
        //动画效果
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * ss = [[UIImageView alloc] initWithImage:[image boxblurImageWithBlur:0.1]];
        ss.tag = kTagRenderImage;
        [self.upView addSubview:ss];
        self.upView.backgroundColor = BLACKCOLOR;
        DLog(@"基图:%p, 覆盖图:%p, renderImage:%p",self.view,self.upView,ss);
        
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        [UIView animateWithDuration:0.5 animations:^{
            ss.alpha = 0.7;
        }];
        
        
        //初始化一个自定义弹窗视图
        UIWindow *myWindow = [[UIWindow alloc] initWithFrame:self.popWindowInitialRect];
        self.window = myWindow;
        myWindow.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:self.windowAlpha];
        myWindow.windowLevel = UIWindowLevelNormal;
        myWindow.hidden = NO;
        myWindow.rootViewController = chooseProductTypeController;
        [myWindow makeKeyAndVisible];
        
        
        //动画出现弹窗视图
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.windowAlpha = 1.0f;
            weakSelf.window.frame =  weakSelf.popWindowDestineRect;
            weakSelf.upView.alpha = 1.0;
        } completion:nil];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        
        [chooseProductTypeController setCancleBarItemHandle:^{
            [weak dismissWithAnimation];
        }];
    }
    if (3 == indexPath.section)
    {
    }
    if (5 == indexPath.section)
    {
        [self performSegueWithIdentifier:@"segueToUserEvalution" sender:self];
    }
}

-(void)dismissWithAnimation {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.window.frame = weakSelf.popWindowInitialRect;
        weakSelf.windowAlpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.window resignKeyWindow];
            weakSelf.window  = nil;
            weakSelf.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }];
    
//    UIView * overlay = VIEWWITHTAG(self.view, kTagOverLay);
    DLog(@"基图:%p 覆盖图:%p",self.view,self.upView);
//    for (id obje in overlay.subviews)
//    {
//        DLog(@"覆盖图的姿势图：%p",obje);
//    }
//    PJAlertAssert(overlay == nil,@"没有获取到覆盖图");
    UIImageView * ss = (UIImageView *)VIEWWITHTAG(self.upView, kTagRenderImage);
    PJAlertAssert(ss == nil,@"没有获取到渲染图");
    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:0.5 animations:^{
        ss.alpha = 1;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.upView.alpha = 0.0;
        } completion:^(BOOL finished) {
        [weakSelf.upView removeFromSuperview];
        weakSelf.upView = nil;
        }];
    }];
}

-(CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [[UIScreen mainScreen] bounds].size.height*-0.02, 0);
    t2 = CATransform3DScale(t2, 0.9, 0.9, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = 0.4/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
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
                              @{@"分享" :@"prodetail_icon_share"},
                              @{@"我的关注" :@"all_pop_attention"},
                              @{@"浏览记录" :@"all_pop_record"}];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 150 - 14, StatusBar_HEIGHT + 78, 150, 250);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr  andType:CZJNIDropDownTypeNormal];
                dropDown.delegate = self;
            }
        }
            break;
            
        case CZJButtonTypeNaviBarBack:
            if (self.myScrollView.contentOffset.y == 0)
            {
                [self.navigationController popViewControllerAnimated:true];
            }
            else
            {
                [self.detailTableView setContentOffset:CGPointZero];
                [self.myScrollView setContentOffset:CGPointZero animated:YES];
            }
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
    [self tapBackground:nil];
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
        CZJMyMessageCenterController* messageCenterVC = (CZJMyMessageCenterController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"MessageCenterSBID"];
        [self.navigationController pushViewController:messageCenterVC animated:YES];
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([btnStr isEqualToString:@"我的关注"])
    {
        CZJMyInfoAttentionController* attentionVC = (CZJMyInfoAttentionController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"myAttentionSBID"];
        [self.navigationController pushViewController:attentionVC animated:YES];
    }
    if ([btnStr isEqualToString:@"浏览记录"])
    {
        CZJMyInfoRecordController* recordVC = (CZJMyInfoRecordController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"myScanRecordSBID"];
        [self.navigationController pushViewController:recordVC animated:YES];
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        NSString* shareUrl;
        if (_detaiViewType == CZJDetailTypeGoods)
        {
            shareUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@",kCZJServerAddr,kCZJGoodsShare,self.storeItemPid];
        }
        if (_detaiViewType == CZJDetailTypeService)
        {
            shareUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@",kCZJServerAddr,kCZJServiceShare,self.storeItemPid];
        }

        NSString* desc = @"我在车之健发现这个不错的商品，赶快去看看吧~";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [CZJUtils downloadImageWithURL:_goodsDetail.imgs.firstObject andFileName:@"detail_icon.png" withSuccess:^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSData* imageData =[NSData dataWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:@"detail_icon.png"]];
            [[ShareMessage shareMessage] showPanel:self.view
                                              type:1
                                             title:_goodsDetail.itemName
                                              body:desc
                                              link:shareUrl
                                             image:imageData];
        } andFail:^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSData* imageData =[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
            [[ShareMessage shareMessage] showPanel:self.view
                                              type:1
                                             title:_goodsDetail.itemName
                                              body:desc
                                              link:shareUrl
                                             image:imageData];
        }];
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
            [self.detailTableView reloadData];
            [CZJUtils tipWithText:@"关注门店成功" andView:self.view];
        }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionStore:params success:^(id json) {
            _storeInfo.attentionFlag = !_storeInfo.attentionFlag;
            _storeInfo.attentionCount = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            [self.detailTableView reloadData];
            [CZJUtils tipWithText:@"取消门店关注" andView:self.view];
        }];
    }
}


#pragma mark- ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
//    DLog(@"contentOffsetY:%f, tableViewContentSizeHeight:%f",contentOffsetY, tableViewContentSizeHeight);
    if (kTagTableView == scrollView.tag && contentOffsetY <=0)
    {
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(0)];
        [self.naviBarView.btnBack setBackgroundColor:RGBA(230, 230, 230, 0.8)];
        [self.naviBarView.btnMore setBackgroundColor:RGBA(230, 230, 230, 0.8)];
        [self.naviBarView.btnShop setBackgroundColor:RGBA(230, 230, 230, 0.8)];
    }
    else if (kTagTableView == scrollView.tag && contentOffsetY > 0)
    {
        float alphaValue = contentOffsetY / 300;
        if (alphaValue > 1)
        {
            alphaValue = 1;
        }
        [self.naviBarView.btnBack setBackgroundColor:RGBA(230, 230, 230,(1 - alphaValue)*0.8)];
        [self.naviBarView.btnMore setBackgroundColor:RGBA(230, 230, 230,(1 - alphaValue)*0.8)];
        [self.naviBarView.btnShop setBackgroundColor:RGBA(230, 230, 230,(1 - alphaValue)*0.8)];
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
    
    if (isButtom && kTagTableView == scrollView.tag && contentOffsetY >= tableViewContentSizeHeight + 40)
    {
        [self.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-114)) animated:true];
        isButtom = NO;
    }
    DLog(@"contentOffsetY:%f, velocity.y:%f, offset:%f",contentOffsetY,velocity.y, targetContentOffset->y);
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


#pragma mark- CZJChooseProductTypeDelegate(规格筛选弹出视图回调)

- (void)productTypeImeditelyBuyCallBack
{
    __weak typeof(self) weak = self;
    [CZJUtils performBlock:^{
        [weak buyNow];
    } afterDelay:0.5];
}

- (void)productTypeAddtoShoppingCartCallBack
{
    __weak typeof(self) weak = self;
    [CZJUtils performBlock:^{
        [weak addGoodsToShoppingCart];
    } afterDelay:0.5];
}

#pragma mark- Action
- (IBAction)immediatelyBuyAction:(id)sender
{
    //如果是秒杀、爆款、没有多余SKU值选择，则不用进入SKU选择界面
    if (CZJGoodsPromotionTypeBaoKuan == _promotionType ||
        CZJGoodsPromotionTypeMiaoSha == _promotionType ||
        [_goodsDetail.sku.skuValues isEqualToString:@"null"] ||
        [_goodsDetail.sku.skuValues isEqualToString:@""] ||
        _detaiViewType == CZJDetailTypeService)
    {
        [self buyNow];
    }
    //如果有多个SKU值则跳转到SKU选择界面
    else
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
        [self tableView:self.detailTableView didSelectRowAtIndexPath:indexPath];
    }
}


- (void)buyNow
{
    [_settleOrderAry removeAllObjects];
    if ([CZJUtils isLoginIn:self andNaviBar:self.naviBarView])
    {
        NSDictionary* itemDict = @{@"itemCode" : goodsDetailForm.goods.itemCode,
                                   @"storeItemPid" : goodsDetailForm.goods.storeItemPid,
                                   @"itemImg" : goodsDetailForm.goods.itemImg,
                                   @"itemName" : goodsDetailForm.goods.itemName,
                                   @"itemSku" : goodsDetailForm.goods.itemSku,
                                   @"itemType" : goodsDetailForm.goods.itemType,
                                   @"itemCount" : @"1",
                                   @"currentPrice" : goodsDetailForm.goods.currentPrice,
                                   @"skillId" : self.skillId == nil ? @"0" : self.skillId,
                                   @"promotionType" : @(_promotionType),
                                   @"promotionPrice" : _promotionPrice == nil ? @"0" : _promotionPrice
                                   };
        
        NSArray* itemAry = @[itemDict];
        NSDictionary* storeDict = @{@"items" :itemAry,
                                    @"storeName" : goodsDetailForm.store.storeName,
                                    @"storeId" :goodsDetailForm.store.storeId,
                                    @"companyId" :goodsDetailForm.store.companyId,
                                    @"selfFlag" : goodsDetailForm.goods.selfFlag ? @"true" : @"false"
                                    };
        [_settleOrderAry addObject:storeDict];
        
        [CZJUtils showCommitOrderView:self andParams:_settleOrderAry];
    }
}

- (IBAction)addProductToShoppingCartAction:(id)sender
{
    //如果是秒杀、爆款、没有多余SKU值选择，则不用进入SKU选择界面
    if (CZJGoodsPromotionTypeBaoKuan == _promotionType ||
        CZJGoodsPromotionTypeMiaoSha == _promotionType ||
        [_goodsDetail.sku.skuValues isEqualToString:@"null"] ||
        [_goodsDetail.sku.skuValues isEqualToString:@""])
    {
        [self addGoodsToShoppingCart];
    }
    //如果有多个SKU值则跳转到SKU选择界面
    else
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
        [self tableView:self.detailTableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)addGoodsToShoppingCart
{
    if ([CZJUtils isLoginIn:self andNaviBar:self.naviBarView])
    {
        NSDictionary* pramas = @{@"companyId" : _goodsDetail.companyId ? _goodsDetail.companyId : @"",
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
        
        [CZJBaseDataInstance addProductToShoppingCart:pramas Success:^(id json){
            
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            DLog(@"%@",[dict description]);
            [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            
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
             if (_detaiViewType == CZJDetailTypeGoods) {
                 [CZJUtils tipWithText:@"关注商品成功" andView:self.view];
             }
             if (_detaiViewType == CZJDetailTypeService)
             {
                 [CZJUtils tipWithText:@"关注服务成功" andView:self.view];
             }
         }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionGoods:params success:^(id json)
         {
             _goodsDetail.attentionFlag = !_goodsDetail.attentionFlag;
             self.attentionBtn.selected = !self.attentionBtn.selected;
             
             if (_detaiViewType == CZJDetailTypeService)
             {
                 [CZJUtils tipWithText:@"取消服务关注" andView:self.view];
             }
             if (_detaiViewType == CZJDetailTypeGoods)
             {
                 [CZJUtils tipWithText:@"取消商品关注" andView:self.view];
             }
         }];
    }
}

- (IBAction)contactServiceAction:(id)sender
{
    if ([CZJUtils isLoginIn:self andNaviBar:nil])
    {
        CZJChatViewController *chatController = [[CZJChatViewController alloc] initWithConversationChatter: _storeInfo.contactAccount conversationType:EMConversationTypeChat];
        chatController.storeName = _storeInfo.storeName;
        chatController.storeId = _storeInfo.storeId;
        chatController.storeImg = _storeInfo.logo;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

- (IBAction)storeAction:(id)sender
{
    CZJStoreDetailController* storeDetailVC = (CZJStoreDetailController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"storeDetailVC"];
    storeDetailVC.storeId = _storeInfo.storeId;
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToUserEvalution"])
    {
        CZJUserEvalutionController* userEvalutionVC = segue.destinationViewController;
        userEvalutionVC.counterKey = goodsDetailForm.goods.counterKey;
    }
}

- (void)tapPromotionCell:(id)sender
{
    DLog(@"%ld",((UIButton*)sender).tag);
    
    CZJPromotionController* promotionVC = (CZJPromotionController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"promotionSBID"];
    promotionVC.type = [NSString stringWithFormat:@"%ld",((UIButton*)sender).tag];
    promotionVC.storeId = goodsDetailForm.goods.storeId;
    [self.navigationController pushViewController:promotionVC animated:YES];
}


#pragma mark- 秒杀
- (void)setTimestamp:(NSInteger)timestamp{
    _timestamp = timestamp;
    if (_timestamp != 0) {
        [self refreshTimeStamp];
        if (!timer) {
            timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimeStamp) userInfo:nil repeats:YES];
        }
    }
}

- (void)refreshTimeStamp
{
    _timestamp--;
    CZJDateTime* mydateTime = [CZJUtils getLeftDatetime:_timestamp];
    miaoShaCell.hourLabel.text = mydateTime.hour;
    miaoShaCell.minutesLabel.text = mydateTime.minute;
    miaoShaCell.secondLabel.text = mydateTime.second;
    
    if (_timestamp == 0) {
        [timer invalidate];
        timer = nil;
        // 执行block回调
        _promotionType = CZJGoodsPromotionTypeGeneral;
        [self getDataFromServer];
    }
}
@end

#pragma mark -
@implementation UIImage (Blur)
- (UIImage*)boxblurImageWithBlur:(CGFloat)blur{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    //不做转换有时候会崩掉
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    CGImageRef img = destImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *boxBluredImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return boxBluredImage;
}
@end


