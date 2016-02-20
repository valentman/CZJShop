//
//  CZJStoreDetailController.m
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CZJStoreDetailController.h"
#import "CZJStoreDetailHeadCell.h"
#import "CZJStoreDescribeTwoCell.h"
#import "CZJStoreDescribeCell.h"
#import "CZJGoodsRecommendCell.h"
#import "CZJGoodsRecoCellHeader.h"
#import "CZJStoreDetailMenuCell.h"
#import "CZJCouponsCell.h"
#import "CZJAdBanerCell.h"
#import "CZJBaseDataManager.h"
#import "CZJShoppingCartForm.h"
#import "CZJStoreDetailForm.h"
#import "CZJDetailForm.h"
#import "HomeForm.h"
#import "CheckInstalledMapAPP.h"
#import "LocationChange.h"
#import "CZJOtherStoreListController.h"
#import "NIDropDown.h"
#import "WyzAlbumViewController.h"
#import "CZJReceiveCouponsController.h"
#import "MXPullDownMenu.h"
#import "CZJGoodsDetailForm.h"

@interface CZJStoreDetailController ()
<
MXPullDownMenuDelegate,
CZJStoreDetailHeadCellDelegate,
CZJImageViewTouchDelegate,
NIDropDownDelegate,
CZJNaviagtionBarViewDelegate,
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
MKMapViewDelegate
>
{
    NSMutableArray* _activityArray;     //活动数据
    NSMutableArray* _imgsArray;         //服务列表
    NSMutableArray* _recommendArray;    //推荐列表
    NSMutableArray* _couponsArray;      //优惠券数据
    NSMutableArray* _bannerOneArray;    //广告条
    NSMutableArray* _goodsTypesArray;   //商品类型
    NSMutableArray* _serviceTypesArray; //服务类型
    NSMutableArray* _serviceAndGoodsArray; //服务和商品
    
    CZJStoreDetailForm* _storeDetailForm;
    float lastContentOffsetY;
    CGRect popViewRect;
    
    NIDropDown *dropDown;
}
@property (strong, nonatomic) IBOutlet CZJNaviagtionBarView *storeNaviBarView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet MXPullDownMenu* topView;
@property (strong, nonatomic) UIView *backgroundView;
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsGd;
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsBd;
@property(nonatomic,assign) CLLocationCoordinate2D nowCoords;

- (IBAction)callAction:(id)sender;
- (IBAction)callNaviAction:(id)sender;
@end

@implementation CZJStoreDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getStoreDetailDataFromServer];
}

- (void)initDatas
{
    lastContentOffsetY = 0;
    _activityArray = [NSMutableArray array];
    _imgsArray = [NSMutableArray array];
    _recommendArray = [NSMutableArray array];
    _couponsArray = [NSMutableArray array];
    _bannerOneArray = [NSMutableArray array];
    _goodsTypesArray = [NSMutableArray array];
    _serviceTypesArray = [NSMutableArray array];
    _serviceAndGoodsArray = [NSMutableArray array];
}

- (void)initViews
{
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.storeNaviBarView initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeStoreDetail].delegate = self;
    [self.storeNaviBarView.customSearchBar setHidden:YES];
    [self.buttomView setBackgroundColor:RGBA(255, 255, 255, 0.9)];
    
    NSArray* nibArys = @[@"CZJStoreDetailHeadCell",
                         @"CZJStoreDescribeCell",
                         @"CZJStoreDescribeTwoCell",
                         @"CZJGoodsRecommendCell",
                         @"CZJAdBanerCell",
                         @"CZJCouponsCell",
                         @"CZJGoodsRecoCellHeader",
                         @"CZJStoreDetailMenuCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.topView.hidden = YES;
    
    //背景触摸层
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    [self.view addSubview:_backgroundView];
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"全部", @"服务", @"商品", @"套餐",@"促销"];
    NSArray* filterTypes = @[@"销量"];
    NSArray* latestTypes = @[@"最新"];
    NSArray* storeTypes = @[@"价格"];
    NSArray* menuArray = @[sortTypes,filterTypes,latestTypes,storeTypes];
    [self.topView initWithArray:menuArray AndType:CZJMXPullDownMenuTypeStoreDetail WithFrame:self.topView.frame].delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)getStoreDetailDataFromServer
{
    NSDictionary* params = @{@"bigTypeId" : @"0",
                             @"typeId" : @"0",
                             @"q" : @"",
                             @"sortType" : @"",
                             @"storeId" : self.storeId,
                             @"storeCityId" : @"469"};
    [CZJBaseDataInstance loadStoreInfo:@{@"storeId" : self.storeId} success:^(id json) {
        [self dealWithData:json];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self.myTableView reloadData];

    } fail:nil];
    
    [CZJBaseDataInstance loadStoreDetail:params success:^(id json) {
        CZJGeneralBlock block = ^()
        {
            [self dealWithGoodsServiceData:json];
        };
        [CZJUtils performBlock:block afterDelay:0.5];
        
    } fail:nil];
}

- (void)dealWithData:(id)json
{
    NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    _storeDetailForm = [[CZJStoreDetailForm alloc]initWithDictionary:[dict valueForKey:@"store"]];
    _imgsArray = [dict valueForKey:@"imgs"];
    
    NSArray* activityTmpAry = [dict valueForKey:@"activitys"];
    for (int i = 0; i < activityTmpAry.count; i++)
    {
        CZJStoreDetailActivityForm* form = [[CZJStoreDetailActivityForm alloc]initWithDictionary:activityTmpAry[i]];
        [_activityArray addObject:form];
    }
    NSArray* bannersTmpAry = [dict valueForKey:@"banners"];
    for (int i = 0; i < bannersTmpAry.count; i++)
    {
        CZJStoreDetailBannerForm* form = [[CZJStoreDetailBannerForm alloc]initWithDictionary:bannersTmpAry[i]];
        [_bannerOneArray addObject:form];
    }
    NSArray* couponsTmpAry = [dict valueForKey:@"coupons"];
    for (int i = 0; i < couponsTmpAry.count; i++)
    {
//        CZJCouponForm* form = [[CZJCouponForm alloc]initWithDictionary:couponsTmpAry[i]];
//        [_couponsArray addObject:form];
    }
    NSArray* goodTypesTmpAry = [dict valueForKey:@"goodsTypes"];
    for (int i = 0; i < goodTypesTmpAry.count; i++)
    {
        CZJStoreDetailTypesForm* form = [[CZJStoreDetailTypesForm alloc]initWithDictionary:goodTypesTmpAry[i]];
        [_goodsTypesArray addObject:form];
        CZJBaseDataInstance.goodsTypesAry = _goodsTypesArray;
    }
    NSArray* serviceTypesTmpAry = [dict valueForKey:@"serviceTypes"];
    for (int i = 0; i < serviceTypesTmpAry.count; i++)
    {
        CZJStoreDetailTypesForm* form = [[CZJStoreDetailTypesForm alloc]initWithDictionary:serviceTypesTmpAry[i]];
        [_serviceTypesArray addObject:form];
        CZJBaseDataInstance.serviceTypesAry = _serviceTypesArray;
    }
    NSArray* recommendTmpAry = [dict valueForKey:@"recommends"];
    for (int i = 0; i < recommendTmpAry.count; i++)
    {
        CZJSToreDetailGoodsAndServiceForm* form = [[CZJSToreDetailGoodsAndServiceForm alloc]initWithDictionary:recommendTmpAry[i]];
        [_recommendArray addObject:form];
    }
}

- (void)dealWithGoodsServiceData:(id)json
{
    [_serviceAndGoodsArray removeAllObjects];
     NSDictionary* dict = [CZJUtils DataFromJson:json];
    NSArray* goodsTmpAry = [dict valueForKey:@"msg"];
    NSMutableArray* serviceGoodsTmpAry = [NSMutableArray array];
    for (int i = 0; i < goodsTmpAry.count; i++)
    {
        GoodsRecommendForm* form = [[GoodsRecommendForm alloc]initWithDictionary:goodsTmpAry[i]];
        [serviceGoodsTmpAry addObject:form];
    }
    float count = (float)serviceGoodsTmpAry.count;
    float count2 = ceilf(count/2);
    [_serviceAndGoodsArray removeAllObjects];
    for (int i  = 0; i < count2; i++)
    {
        NSMutableArray* array = [NSMutableArray array];
        [_serviceAndGoodsArray addObject:array];
    }
    for (int i = 0; i < count; i++) {
        int index = i / 2;
        [_serviceAndGoodsArray[index] addObject:serviceGoodsTmpAry[i]];
    }
    if (_serviceAndGoodsArray.count > 0)
    {
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    if (1 == section)
    {
        return _couponsArray.count > 0 ? 1 : 0;
    }
    if (2 == section)
    {
        return _bannerOneArray.count > 0 ? 1 : 0;
    }
    if (3 == section)
    {
        return _imgsArray.count;
    }
    if (4 == section)
    {
        return ceilf(_recommendArray.count/2) > 0 ? ceilf(_recommendArray.count/2) + 1 : 0;
    }
    if (5 == section)
    {
        return _serviceAndGoodsArray.count > 0 ? _serviceAndGoodsArray.count + 2 : 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJStoreDetailHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailHeadCell" forIndexPath:indexPath];
            cell.storeAddrLabel.text = _storeDetailForm.storeAddr;
            cell.storeNameLabel.text = _storeDetailForm.storeName;
            cell.attentionCountLabel.text = _storeDetailForm.attentionCount;
            [cell.attentionBtn setImage:IMAGENAMED(_storeDetailForm.attentionFlag ? @"shop_icon_guanzhu_sel" : @"shop_icon_guanzhu") forState:UIControlStateNormal];
            cell.headImgLayoutWidth.constant = 0;
            cell.storeNameLayoutWidth.constant = [CZJUtils calculateStringSizeWithString:_storeDetailForm.storeName Font:SYSTEMFONT(16) Width:200].width;
            cell.delegate = self;
            cell.attentionDelegate = self;
            if (!cell.isInit && _imgsArray.count > 0) {
                [cell someMethodNeedUse:indexPath DataModel:[@[_imgsArray.firstObject]mutableCopy]];
            }
            
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJStoreDescribeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeCell" forIndexPath:indexPath];
            cell.envirmentScoreLabel.text = _storeDetailForm.environmentScore;
            cell.describeScoreLabel.text = _storeDetailForm.descScore;
            cell.deliveryScoreLabel.text = _storeDetailForm.deliveryScore;
            cell.serviceScoreLabel.text = _storeDetailForm.serviceScore;
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJStoreDescribeTwoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeTwoCell" forIndexPath:indexPath];
            cell.serviceLabel.text = _storeDetailForm.serviceCount;
            cell.promotionLabel.text = _storeDetailForm.promotionCount;
            cell.setMenuLabel.text = _storeDetailForm.setmenuCount;
            cell.goodsLabel.text = _storeDetailForm.goodsCount;
            return cell;
        }
    }
    if (1 == indexPath.section && 0 == indexPath.row)
    {//领券
        CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
        if (cell && _couponsArray.count > 0 && !cell.isInit)
        {
            [cell initWithCouponDatas:_couponsArray];
        }
        return cell;
    }
    if (2 == indexPath.section && 0 == indexPath.row)
    {//广告一
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        [cell initBannerOneWithDatas:_bannerOneArray];
        return cell;
    }
    if (3 == indexPath.section)
    {//广告二
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        [cell initBannerWithImg:_imgsArray[indexPath.row]];
        return cell;
    }
    if (4 == indexPath.section)
    {//推荐商品或服务
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            headerView.recoMenuLabel.text = @"爆款专区";
            return headerView;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            headerView.recoMenuLabel.text = @"服务和商品";
            headerView.recoViewLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:@"服务和商品" WithFont:headerView.recoMenuLabel.font].width;
            return headerView;
        }
        else if (1 == indexPath.row)
        {
            CZJStoreDetailMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailMenuCell" forIndexPath:indexPath];
            [cell setTag:500];
            return cell;
        }
        else
        {
            CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
            if (cell && _serviceAndGoodsArray.count > 0) {
                [cell initGoodsRecommendWithDatas:_serviceAndGoodsArray[indexPath.row - 2]];
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
            return 280;
        }
        if (1 == indexPath.row)
        {
            return 60;
        }
        if (2 == indexPath.row)
        {
            return 139;
        }
    }
    if (1 == indexPath.section)
    {
        return 50;
    }
    if (2 == indexPath.section)
    {
        return 100;
    }
    if (3 == indexPath.section)
    {
        return 150;
    }
    if (4 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 50;
        }
        if (1 == indexPath.row)
        {
            return 245;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 50;
        }
        else if (1 == indexPath.row)
        {
            return 44;
        }
        else
        {
            return 245;
        }
    }
    return 180;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section)
    {
        popViewRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        UIWindow *window = [[UIWindow alloc] initWithFrame:popViewRect];
        window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        window.windowLevel = UIWindowLevelNormal;
        window.hidden = NO;
        [window makeKeyAndVisible];
        
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        window.rootViewController = receiveCouponsController;
        self.window = window;
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [view addGestureRecognizer:tap];
        [self.view addSubview:view];
        self.upView = view;
        self.upView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.window.frame =  CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
            self.upView.alpha = 1.0;
        } completion:nil];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        __weak typeof(self) weak = self;
        [receiveCouponsController setCancleBarItemHandle:^{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weak.window.frame = popViewRect;
                self.upView.alpha = 0.0;
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
}

- (void)tapAction{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.window.frame = popViewRect;
        self.upView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.upView removeFromSuperview];
            [self.window resignKeyWindow];
            self.window  = nil;
            self.upView = nil;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section ||
        3 == section)
    {
        return 0;
    }
    return 10;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
};


#pragma mark- ScrollViewDelegate
// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    bool isDraggingDown = (lastContentOffsetY - contentOffsetY) > 0 ;
    lastContentOffsetY = contentOffsetY;
    
    

    UIView* view = VIEWWITHTAG(self.myTableView, 500);
    CGRect frame = view.frame;
    DLog(@"frame:%f, contentOffsetY:%f",frame.origin.y, contentOffsetY);
    if (view &&
        ((contentOffsetY <= frame.origin.y - 66 && isDraggingDown)||
        (contentOffsetY >= frame.origin.y - 66 && !isDraggingDown)))
    {
        self.topView.hidden = isDraggingDown;
    }
    
    if (contentOffsetY > 0)
    {
        float alphaValue = contentOffsetY / 300;
        if (alphaValue > 1)
        {
            alphaValue = 1;
            self.naviBarView.customSearchBar.hidden = NO;
        }
        else
        {
            self.naviBarView.customSearchBar.hidden = YES;
        }
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(alphaValue)];
    }
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeSearchBar:
            
            break;
            
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = [[NSArray alloc] init];
            arr = [NSArray arrayWithObjects:@{@"消息" : @"prodetail_icon_msg"}, @{@"首页":@"prodetail_icon_home"}, @{@"分享" :@"prodetail_icon_share"},nil];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 150);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
                dropDown.delegate = self;
            }
        }
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

#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        DLog(@"首页");
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        DLog(@"分享");
    }
}


#pragma mark- CZJImageTouchViewDelegate
- (void)showDetailInfoWithIndex:(NSInteger)index
{
    WyzAlbumViewController *wyzAlbumVC = [[WyzAlbumViewController alloc]init];
    wyzAlbumVC.currentIndex =index;//这个参数表示当前图片的index，默认是0
    //用url
    wyzAlbumVC.imgArr = _imgsArray;
    //进入动画
    [self presentViewController:wyzAlbumVC animated:YES completion:^{
    }];
}


#pragma mark- CZJStoreDetailHeadCellDelegate
- (void)clickAttentionButton:(id)sender
{
    _storeDetailForm.attentionFlag = !_storeDetailForm.attentionFlag;
    if (_storeDetailForm.attentionFlag) {
        [CZJBaseDataInstance attentionStore:@{@"storeId" : _storeDetailForm.storeId} success:^(id json) {
            
        }];
        _storeDetailForm.attentionCount = [NSString stringWithFormat:@"%ld",[_storeDetailForm.attentionCount integerValue] + 1];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionStore:@{@"storeId" : _storeDetailForm.storeId} success:^(id json) {
            
        }];
        _storeDetailForm.attentionCount = [NSString stringWithFormat:@"%ld",[_storeDetailForm.attentionCount integerValue] - 1];
    }
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark- MXPullDownMenuDelegate
- (void)pullDownMenuDidSelectFiliterButton
{
    
}

- (void)pullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectCityName:(NSString*)cityName
{
    DLog(@"%@",cityName);
}

#pragma mark- Actions
- (IBAction)callAction:(id)sender {
    [CZJUtils callHotLine:_storeDetailForm.hotline AndTarget:self.view];
    
}


- (IBAction)callNaviAction:(id)sender {
    NSArray *appListArr = [CheckInstalledMapAPP checkHasOwnApp];
    NSString *sheetTitle = [NSString stringWithFormat:@"导航到 %@",_storeDetailForm.storeAddr];
    
    UIActionSheet *sheet;
    if ([appListArr count] == 2) {
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1], nil];
    }else if ([appListArr count] == 3){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2], nil];
    }else if ([appListArr count] == 4){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3], nil];
    }else if ([appListArr count] == 5){
        sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:appListArr[0],appListArr[1],appListArr[2],appListArr[3],appListArr[4], nil];
    }
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == 0) {
        if (IOS_VERSION < 6) {//ios6 调用goole网页地图
            NSString *urlString = [[NSString alloc]
                                   initWithFormat:@"http://maps.google.com/maps?saddr=&daddr=%.8f,%.8f&dirfl=d",self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
            
            NSURL *aURL = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:aURL];
        }else{//ios7 跳转apple map
            CLLocationCoordinate2D to;
            
            to.latitude = [_storeDetailForm.lat floatValue];
            to.longitude = [_storeDetailForm.lng floatValue];
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
            
            toLocation.name = _storeDetailForm.storeAddr;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
    }
    if ([btnTitle isEqualToString:@"google地图"]) {
//        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",self.nowCoords.latitude,self.nowCoords.longitude,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if ([btnTitle isEqualToString:@"高德地图"]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2",_storeDetailForm.storeAddr,self.naviCoordsGd.latitude,self.naviCoordsGd.longitude]];
        [[UIApplication sharedApplication] openURL:url];
        
    }else if ([btnTitle isEqualToString:@"百度地图"]){
        double bdNowLat,bdNowLon;
        bd_encrypt(self.nowCoords.latitude, self.nowCoords.longitude, &bdNowLat, &bdNowLon);
        
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving",bdNowLat,bdNowLon,self.naviCoordsBd.latitude,self.naviCoordsBd.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }else if ([btnTitle isEqualToString:@"显示路线"]){
//        [self drawRout];
    }
}

#pragma mark MKMapViewDelegate -user location定位变化
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    self.nowCoords = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
//    self.userRegion = MKCoordinateRegionMakeWithDistance(self.nowCoords, 200, 200);
//    
//    if (self.mapType != RegionNavi) {
//        if (self.updateInt >= 1) {
//            return;
//        }
//        [self showAnnotation:userLocation.location coord:self.nowCoords];
//        [self.regionMapView setRegion:self.userRegion animated:NO];
//    }
}
//-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    if (self.mapType == RegionNavi) {
//        return;
//    }
//    if (ISIOS7) {
//        if ([mapView.annotations count]) {
//            [mapView removeAnnotations:mapView.annotations];
//        }
//    }
//    
//    if (self.updateInt == 0){
//        return;
//    }
//    self.centerCoordinate = mapView.region.center;
//    
//    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.centerCoordinate.latitude longitude:self.centerCoordinate.longitude];
//    
//    [self showAnnotation:loc coord:centerCoordinate];
//}
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
//    if (self.mapType == RegionNavi) {
//        return;
//    }
//    if (ISIOS7) {
//        if ([mapView.annotations count]) {
//            [mapView removeAnnotations:mapView.annotations];
//        }
//    }
//}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToStoreList"])
    {
        CZJOtherStoreListController* vc = segue.destinationViewController;
        vc.storeID = _storeDetailForm.storeId;
        vc.companyId = _storeDetailForm.companyId;
    }
}

@end
