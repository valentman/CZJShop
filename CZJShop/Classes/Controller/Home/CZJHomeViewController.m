//
//  CZJHomeViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 11/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJHomeViewController.h"
#import "CZJBaseDataManager.h"
#import "PullTableView.h"
#import "CZJScanQRController.h"
#import "HomeForm.h"
#import "CZJActivityCell.h"
#import "CZJServiceCell.h"
#import "CZJCarInfoCell.h"
#import "CZJMiaoShaCellHeader.h"
#import "CZJMiaoShaCell.h"
#import "CZJAdBanerCell.h"
#import "CZJLimitBuyCellHeader.h"
#import "CZJLimitBuyCell.h"
#import "CZJBrandRecoCellHeader.h"
#import "CZJBrandRecommendCell.h"
#import "CZJAdBanerPlusCell.h"
#import "CZJSpecialRecoCellHeader.h"
#import "CZJSpecialRecommendCell.h"
#import "CZJGoodsRecoCellHeader.h"
#import "CZJGoodsRecommendCell.h"
#import "CZJServiceListController.h"
#import "CZJShoppingCartController.h"
#import "CZJDetailViewController.h"
#import "CZJCategoryController.h"
#import "CZJMiaoShaController.h"
#import "CZJNetworkManager.h"
#import "AppDelegate.h"

@interface CZJHomeViewController ()<
UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource,
UIAlertViewDelegate,
CZJNaviagtionBarViewDelegate,
CZJImageViewTouchDelegate,
CZJServiceCellDelegate,
CZJGoodsRecommendCellDelegate,
CZJMiaoShaCellDelegate
>
{
    __block CZJVersionForm* versionForm;
    
    CZJHomeGetDataFromServerType _refreshType;
    MJRefreshAutoNormalFooter* refreshFooter;
    MJRefreshGifHeader* refreshHeader;
    CZJCarInfoCell * carInfoCell;
    __block CZJMiaoShaCellHeader* miaoShaHeaderCell;
    
    NSMutableArray* _activityArray;                 //活动数据
    NSMutableArray* _serviceArray;                  //服务列表
    NSMutableArray* _carInfoArray;                  //汽车资讯
    NSMutableArray* _miaoShaArray;                  //秒杀数据
    NSMutableArray* _bannerOneArray;                //广告条
    NSMutableArray* _limitBuyArray;                 //限量抢购数据
    NSMutableArray* _brandRecommentArray;           //品牌推荐数据
    NSMutableArray* _bannerTwoArray;                //第二个广告条
    NSMutableArray* _specialRecommentArray;         //特别推荐数据
    NSMutableArray* _goodsRecommentArray;           //商品推荐数据
    
    NSString* _curSeviceType;                       /***<-当前选择的服务类型*/
    NSString* _curSeviceName;
    NSString* _webViewTitle;
    NSString* _serviceTypeId;
    GoodsRecommendForm* _touchedRecommendForm;
    
    UIView* _errorView;
    UISearchBar* customSearchBar;
    
    UIButton* btnScan;
    UIButton* btnShop;
    
    BOOL isLoadSuccess;
    
    //===========每个Cell单独设置刷新标识============
    __block BOOL _isAllRefresh;
    __block BOOL _isBannerOneRefresh;
    __block BOOL _isLimitRefresh;
    __block BOOL _isBrandRecoRefresh;
    __block BOOL _isBannerTwoRefresh;
    __block BOOL _isSpecialRefresh;
    __block BOOL _isRefreshMiaoshaCell;
    
    BOOL _isFirstInNetWorkReachable;
}
@property (strong, nonatomic)NSString* recommandId;
@property (nonatomic,retain)NSString* curUrl;
@property (nonatomic, assign)EWebHtmlType htmlType;
@property (nonatomic, assign)BOOL isFirst;
@property (nonatomic, assign)BOOL isJumpToAnotherView;
@property (nonatomic,assign)int page;

@property (strong, nonatomic) IBOutlet UITableView *homeTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnToTop;

- (IBAction)tapToTop:(id)sender;
@end

@implementation CZJHomeViewController


#pragma mark- InitSection

- (void)viewDidLoad {
    [super viewDidLoad];
    [self propertysInit];
    [self dealWithInitNavigationBar];
    [self dealWithInitTableView];
    [self dealWithInitTabbar];
    [self getHomeDataFromServer];
    [self.homeTableView reloadData];
    [CZJUtils setExtraCellLineHidden:self.homeTableView];
    [CZJUtils performBlock:^{
        [self checkTheLatestVersion];
    } afterDelay:0.5];
    [self checkNetWorkStatus];
    _isFirstInNetWorkReachable = _isNetWorkCanReachable;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.naviBarView refreshShopBadgeLabel];
    self.naviBarView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    //注册进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimer) name:@"stopTimer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTimer) name:@"beginTimer" object:nil];
}

- (void)stopTimer
{
    [carInfoCell.autoScrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)beginTimer
{
    [carInfoCell.autoScrollTimer setFireDate:[NSDate distantPast]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.isJumpToAnotherView = YES;
    [self beginTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimer];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"stopTimer" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"beginTimer" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)propertysInit
{
    //隐藏toTop按钮
    _isRefreshMiaoshaCell = YES;
    _isAllRefresh = YES;
    _isBannerOneRefresh = YES;
    _isLimitRefresh = YES;
    _isBrandRecoRefresh = YES;
    _isBannerTwoRefresh = YES;
    _isSpecialRefresh = YES;
    self.btnToTop.hidden = YES;
    self.isFirst = YES;
    self.isJumpToAnotherView = NO;
    self.page = 0;
    _refreshType = CZJHomeGetDataFromServerTypeOne;
}

- (void)dealWithInitNavigationBar
{
    /**
     *  注意：一旦你设置了navigationBar的- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics接口，那么上面的setBarTintColor接口就不能改变statusBar的背景色
     */
    //导航栏背景透明化
    id navigationBarAppearance = self.navigationController.navigationBar;
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"nav_bargound"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.navigationBar.shadowImage =[UIImage imageNamed:@"nav_bargound"];
    self.navigationController.navigationBarHidden = YES;
    
    //导航栏添加搜索栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeSearch];
    [self.naviBarView setBackgroundColor:RGBA(235, 35, 38, 0)];
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
}


- (void)dealWithInitTableView
{
    self.homeTableView.delegate = self;
    self.homeTableView.dataSource = self;
    [self.homeTableView setDelegate:self];
    self.homeTableView.showsVerticalScrollIndicator = NO;
    self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.homeTableView.rowHeight = UITableViewAutomaticDimension;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.homeTableView.clipsToBounds = NO;
    self.homeTableView.backgroundColor = CLEARCOLOR;
    
    NSArray* nibArys = @[@"CZJActivityCell",
                         @"CZJServiceCell",
                         @"CZJCarInfoCell",
                         @"CZJMiaoShaCell",
                         @"CZJMiaoShaCellHeader",
                         @"CZJAdBanerCell",
                         @"CZJLimitBuyCellHeader",
                         @"CZJLimitBuyCell",
                         @"CZJBrandRecoCellHeader",
                         @"CZJBrandRecommendCell",
                         @"CZJAdBanerPlusCell",
                         @"CZJSpecialRecoCellHeader",
                         @"CZJSpecialRecommendCell",
                         @"CZJGoodsRecoCellHeader",
                         @"CZJGoodsRecommendCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.homeTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    //添加MJRefresh上拉下拉刷新控件
    __weak typeof(self) weak = self;
    refreshHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        _isAllRefresh = YES;
        _isBannerOneRefresh = YES;
        _isLimitRefresh = YES;
        _isBrandRecoRefresh = YES;
        _isBannerTwoRefresh = YES;
        _isSpecialRefresh = YES;
        _refreshType = CZJHomeGetDataFromServerTypeOne;
        weak.page = 0;
        [refreshFooter resetNoMoreData];
        [weak getHomeDataFromServer];
    }];
    self.homeTableView.header = refreshHeader;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _refreshType = CZJHomeGetDataFromServerTypeTwo;
        weak.page++;
        [weak getRecommendDataFromServer];
    }];
    self.homeTableView.footer = refreshFooter;
    self.homeTableView.footer.backgroundColor = CZJNAVIBARBGCOLOR;
}

- (void)dealWithInitTabbar
{
    //TabBarItem选中颜色设置及右上角标记设置
    [self.tabBarController.tabBar setTintColor:RGB(235, 20, 20)];
        
}


- (void)getHomeDataFromServer
{
    //进入首页即获取首页数据
    __weak typeof(self) weak = self;
    if (miaoShaHeaderCell)
    {
        miaoShaHeaderCell.isInit = NO;
        _isRefreshMiaoshaCell = YES;
    }
    
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        DLog(@"%@",[[CZJUtils DataFromJson:json] description]);
        [CZJBaseDataInstance.homeForm setNewDictionary:[CZJUtils DataFromJson:json]];
        if (CZJBaseDataInstance.storeForm.provinceForms.count == 0)
        {
            [CZJBaseDataInstance getAreaInfos];
        }
        isLoadSuccess = YES;
        [weak dealWithArray];
        [weak.homeTableView reloadData];
        [weak.homeTableView.header endRefreshing];
        weak.page++;
        [weak getRecommendDataFromServer];
        
    } fail:^{
        [weak.homeTableView.header endRefreshing];
    } andServerAPI:kCZJServerAPIShowHome];
    
    //获取购物车数量（登录状态）
    [USER_DEFAULT setObject:@"0" forKey:kUserDefaultShoppingCartCount];
    if ([USER_DEFAULT boolForKey:kCZJIsUserHaveLogined])
    {
        [CZJBaseDataInstance loadShoppingCartCount:nil Success:^(id json){
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            [weak.naviBarView refreshShopBadgeLabel];
        } fail:nil];
    }
}

- (void)getRecommendDataFromServer
{
    //随机码，每五分钟更新一次随机码获取不同的推荐商品
    srand((unsigned)time(0));
    int randNum = [[USER_DEFAULT valueForKey:kUserDefaultRandomCode]intValue];
    if ([CZJUtils isTimeCrossFiveMin:5] && 1 == self.page)
    {
        randNum = rand()%900000+100000;
        [USER_DEFAULT setValue:@(randNum) forKey:kUserDefaultRandomCode];
    }
    NSDictionary* recommendParams = @{@"page" : @(self.page), @"randomCode" : @(randNum)};
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:recommendParams success:^(id json) {
        //推荐商品分页返回数据
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"recommend:%@",[[CZJUtils DataFromJson:json] description]);
        if (tmpAry.count < 20)
        {
            [refreshFooter noticeNoMoreData];
        }
        else
        {
            [weak.homeTableView.footer endRefreshing];
        }
        [CZJBaseDataInstance.homeForm  appendGoodsRecommendDataWith:[CZJUtils DataFromJson:json]];
        [weak dealWithArray];
        [weak.homeTableView reloadData];
        _isAllRefresh = NO;
        weak.homeTableView.footer.hidden = weak.homeTableView.mj_contentH < weak.homeTableView.frame.size.height;
    } fail:^{
        [weak.homeTableView.footer endRefreshing];
    } andServerAPI:kCZJServerAPIGetRecoGoods];
}

- (void)dealWithArray
{
    _activityArray = [CZJBaseDataInstance  homeForm].activityFroms;
    _serviceArray = [CZJBaseDataInstance  homeForm].serviceForms;
    _carInfoArray = [CZJBaseDataInstance  homeForm].carInfoForms;
    _miaoShaArray = [CZJBaseDataInstance  homeForm].secSkillForms;
    _bannerOneArray = [CZJBaseDataInstance  homeForm].bannerOneForms;
    _limitBuyArray = [CZJBaseDataInstance  homeForm].limitBuyForms;
    _brandRecommentArray = [CZJBaseDataInstance  homeForm].brandRecommendForms;
    _bannerTwoArray = [CZJBaseDataInstance  homeForm].bannerTwoForms;
    _specialRecommentArray = [CZJBaseDataInstance  homeForm].specialRecommendForms;
    _goodsRecommentArray = [CZJBaseDataInstance  homeForm].goodRecommendFromGroupedAry;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //依据不同的内容加载不同类型的Cell
    switch (indexPath.section) {
        case 0:
        {//ad广告展示
            CZJActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJActivityCell" forIndexPath:indexPath];
            if (_activityArray.count > 0 && _isAllRefresh)
            {
                [cell someMethodNeedUse:indexPath DataModel:_activityArray];
                cell.delegate = self;
            }
            return cell;
        }
            break;
            
        case 1:
        {//服务列表
            CZJServiceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJServiceCell" forIndexPath:indexPath];
            if ((cell && _serviceArray.count > 0 && _isAllRefresh) ||
                (CZJHomeGetDataFromServerTypeOne == _refreshType))
            {
                [cell initServiceCellWithDatas:_serviceArray];
                cell.delegate = self;
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 2:
        {//汽车资讯
            carInfoCell = [tableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell" forIndexPath:indexPath];
            if (carInfoCell && _carInfoArray.count > 0 && _isAllRefresh)
            {
                __weak typeof(self) weak = self;
                [carInfoCell initWithCarInfoDatas:_carInfoArray andButtonClick:^(id data) {
                    CarInfoForm* carInfoForm = (CarInfoForm*)data;
                    [weak showWebViewWithURL:carInfoForm.url];
                }];
            }
            [carInfoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return carInfoCell;
        }
            break;
            
        case 3:
        {//秒杀数据
            if (1 == indexPath.row) {
                CZJMiaoShaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCell" forIndexPath:indexPath];
                if (cell && _miaoShaArray.count > 0 && _isRefreshMiaoshaCell)
                {
                    _isRefreshMiaoshaCell = NO;
                    cell.delegate = self;
                    [cell initMiaoShaInfoWithData:_miaoShaArray];
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (0 == indexPath.row)
            {
                miaoShaHeaderCell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCellHeader" forIndexPath:indexPath];
                
                if (miaoShaHeaderCell && _miaoShaArray.count > 0 && _isAllRefresh)
                {
                    //获取服务器返回当前时间
                    NSInteger currentTime = [CZJBaseDataInstance.homeForm.serverTime integerValue];
                    
                    //获取最近秒杀场场点时间
                    NSInteger skillTime = 0;
                    for (int i = 0; i < CZJBaseDataInstance.homeForm.skillTimes.count; i++)
                    {
                        CZJMiaoShaTimesForm* timeForm = CZJBaseDataInstance.homeForm.skillTimes[i];
                        skillTime = [timeForm.skillTime integerValue];
                        if (skillTime > currentTime)
                        {
                            
                            CZJMiaoShaTimesForm* timeForms = CZJBaseDataInstance.homeForm.skillTimes[(i - 1 < 0 ? 0 : i - 1)];
                            NSString* timeStr = [NSString stringWithFormat:@"%@场",[CZJUtils getDateTimeSinceTime:[timeForms.skillTime integerValue] / 1000]];
                            NSRange range = {2,4};
                            NSString* timerStrRange = [timeStr stringByReplacingCharactersInRange:range withString:@""];
                            NSRange range2 = {0,1};
                            NSString* timeStrFirstNumb = [timerStrRange substringWithRange:range2];
                            if ([timeStrFirstNumb isEqualToString:@"0"])
                            {
                                timerStrRange = [timerStrRange stringByReplacingOccurrencesOfString:@"0" withString:@""];
                            }
                            
                            miaoShaHeaderCell.miaoShaChangCiLabel.text = [NSString stringWithFormat:@"%@点场",timerStrRange];
                            break;
                        }
                    }
                    
                    //倒计时差值
                    NSInteger timeinteval = (skillTime - currentTime) / 1000;
                    [miaoShaHeaderCell initHeaderWithTimestamp:timeinteval];
                    
                    //倒计时结束后的回调
                    __weak typeof(self) weak = self;
                    miaoShaHeaderCell.buttonClick = ^(id data){
                        _isRefreshMiaoshaCell = YES;
                        _isAllRefresh = YES;
                        _isBannerOneRefresh = YES;
                        _isLimitRefresh = YES;
                        _isBrandRecoRefresh = YES;
                        _isBannerTwoRefresh = YES;
                        _isSpecialRefresh = YES;
                        [weak getHomeDataFromServer];
                    };
                }
                
                return miaoShaHeaderCell;
            }
        }
            break;
            
        case 4:
        {//广告栏一
            CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
            cell.delegate = self;
            if (_bannerOneArray.count > 0 && _isBannerOneRefresh)
            {
                _isBannerOneRefresh = NO;
                [cell initBannerOneWithDatas:_bannerOneArray];
            }
            return cell;
        }
            break;
            
        case 5:
        {//限量购买
            if (0 == indexPath.row)
            {
                CZJLimitBuyCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCellHeader" forIndexPath:indexPath];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJLimitBuyCell *cell = (CZJLimitBuyCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCell" forIndexPath:indexPath];
                if (cell && _limitBuyArray.count > 0 && _isLimitRefresh)
                {
                    _isLimitRefresh = NO;
                    [cell initLimitBuyWithDatas:_limitBuyArray];
                }
                return cell;
            }
            
        }
            break;
            
        case 6:
        {//品牌推荐
            if (0 == indexPath.row)
            {
                CZJBrandRecoCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJBrandRecoCellHeader" forIndexPath:indexPath];
                return cell;
            }
            if (1 == indexPath.row)
            {
                CZJBrandRecommendCell *cell = (CZJBrandRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJBrandRecommendCell" forIndexPath:indexPath];
                if (cell && _brandRecommentArray.count > 0 && _isBrandRecoRefresh)
                {
                    _isBrandRecoRefresh = NO;
                    cell.delegate = self;
                    [cell initBrandRecommendWithDatas:_brandRecommentArray];
                }
                return cell;
            }
        }
            break;
            
        case 7:
        {//广告条二
            CZJAdBanerPlusCell *cell = (CZJAdBanerPlusCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerPlusCell" forIndexPath:indexPath];
            cell.delegate = self;
            if (_bannerTwoArray.count > 0 && _isBannerTwoRefresh)
            {
                _isBannerTwoRefresh = NO;
                [cell initBannerTwoWithDatas:_bannerTwoArray];
            }
            return cell;
        }
            break;
            
        case 8:
        {//特别推荐
            if (0 == indexPath.row)
            {
                CZJSpecialRecoCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecoCellHeader" forIndexPath:indexPath];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJSpecialRecommendCell *cell = (CZJSpecialRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecommendCell" forIndexPath:indexPath];
                if (cell && _specialRecommentArray.count > 0 && _isSpecialRefresh)
                {
                    _isSpecialRefresh = NO;
                    cell.delegate = self;
                    [cell initSpecialRecommendWithDatas:_specialRecommentArray];
                }
                return cell;
            }
        }
            break;
            
        case 9:
        {
            if (0 == indexPath.row)
            {
                CZJGoodsRecoCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
                cell.backgroundColor = CZJNAVIBARBGCOLOR;
                return cell;
            }
            else
            {
                CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
                cell.delegate = self;
                float width = (PJ_SCREEN_WIDTH - 30) / 2;
                cell.imageOneHeight.constant = width;
                cell.imageTwoHeight.constant = width;
                cell.backgroundColor = CZJNAVIBARBGCOLOR;
                [cell initGoodsRecommendWithDatas:_goodsRecommentArray[indexPath.row - 1]];
                return cell;
            }
        }
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //广告条和汽车头条可能没有信息数据，则返回0
    if (isLoadSuccess && ((_bannerOneArray.count == 0 && section == 4)||
        (_bannerTwoArray.count == 0 && section == 7)||
        (_carInfoArray.count == 0 && section == 2) ||
        (_specialRecommentArray.count == 0 && section == 8) ||
        (_brandRecommentArray.count == 0 && section == 6)))
    {
        return 0;
    }
    if ((_limitBuyArray.count == 0 && section == 5) ||
        (_miaoShaArray.count == 0 && section == 3))
    {
        return 0;
    }
    if (9 == section)
    {
        return _goodsRecommentArray.count + 1;
    }
    if ((_miaoShaArray.count > 0 && section == 3)||
        5 == section ||
        6 == section ||
        8 == section)
    {
        return 2;
    }
    return 1;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 210;
            break;
        case 1:
            return 170;
            break;
        case 2:
            return 39;
            break;
        case 3:
            if (0 == indexPath.row) {
                return 40;
            }
            if (1 == indexPath.row) {
                return 135;
            }
            break;
        case 4:
            return 100;
            break;
        case 5:
            if (0 == indexPath.row) {
                return 40;
            }
            if (1 == indexPath.row) {
                return 135;
            }
            break;
        case 6:
            if (0 == indexPath.row) {
                return 40;
            }
            if (1 == indexPath.row) {
                return 188;
            }
            break;
            
        case 7:
            return 100;
            break;
        case 8:
            if (0 == indexPath.row) {
                return 40;
            }
            if (1 == indexPath.row) {
                return 200;
            }
            break;
        case 9:
            if (0 == indexPath.row) {
                return 50;
            }
            if (1 <= indexPath.row) {
                float width = (PJ_SCREEN_WIDTH - 30) / 2;
                return width + 5 + 40 + 10 +15 + 10 + 10;
            }
            break;
        default:
            return 200;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (isLoadSuccess)
    {
        if (
            (_miaoShaArray.count != 0 && section == 3)||
            (_bannerOneArray.count != 0 && section == 4)||
            (_limitBuyArray.count != 0 && section == 5)||
            (_brandRecommentArray.count != 0 && section == 6)||
            (_bannerTwoArray.count != 0 && section == 7)||
            (_specialRecommentArray.count != 0 && section == 8)){
            return 10;
        }
    }
    else
    {
        if (
            (section == 3)||
            (section == 6)||
            (section == 7)||
            (section == 8)){
            return 10;
        }
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (3 == indexPath.section)
    {
        [self performSegueWithIdentifier:@"segueToMiaoSha" sender:nil];
    }
    if (6 == indexPath.section && 0 == indexPath.row)
    {
        
        [self showWebViewWithURL:@""];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isJumpToAnotherView) {
        return;
    }
    float contentOffsetY = [scrollView contentOffset].y;
    if (contentOffsetY < 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.naviBarView setAlpha:0.0];
        }];
        [self.naviBarView setBackgroundColor:RGBA(235, 35, 38, 0)];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            [self.naviBarView setAlpha:1.0];
        }];
        
        float alphaValue = contentOffsetY / 200;
        if (alphaValue > 0.8)
        {
            alphaValue = 0.8;
        }
        [self.naviBarView setBackgroundColor:RGBA(235, 35, 38, alphaValue)];
    }
    
    if (contentOffsetY > 600)
    {
        self.btnToTop.hidden = NO;
    }
    else
    {
        self.btnToTop.hidden = YES;
    }
}


#pragma mark- CZJActivityDelegate
- (void)showDetailInfoWithForm:(id)form
{
    ServiceForm* serviceForm = (ServiceForm*)form;
    if ([serviceForm.type isEqualToString:@"5"] ||
        [serviceForm.type isEqualToString:@"6"])
    {
        CZJCategoryController* cateVC = (CZJCategoryController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"CategorySBID"];
        cateVC.viewFromWhere = serviceForm.type;
        [self.navigationController pushViewController:cateVC animated:YES];
//        self.tabBarController.selectedIndex = 1;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"moreService" object:nil];
    }
    else
    {
        _serviceTypeId = serviceForm.typeId;
        [USER_DEFAULT setValue:_serviceTypeId forKey:kUserDefaultServiceTypeID];
        [self performSegueWithIdentifier:@"pushToServiceDetail" sender:self];
    }
}

-(void)showActivityHtmlWithUrl:(NSString*)url
{
    [self showWebViewWithURL:url];
}

#pragma mark- CZJMiaoShaCellDelegate
- (void)clickMiaoShaCellItem:(id)sender
{
    [self performSegueWithIdentifier:@"segueToMiaoSha" sender:nil];
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    self.isJumpToAnotherView = YES;
    switch ([sender tag]) {
        case CZJButtonTypeHomeScan:
            [self performSegueWithIdentifier:@"pushToScanQR" sender:self];
            break;
            
        case CZJButtonTypeHomeShopping:
            break;
            
        default:
            break;
    }
}

- (void)removeShoppingOrLoginView:(nullable id)sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark- CZJGoodsRecommendCellDelegate
- (void)clickRecommendCellWithID:(GoodsRecommendForm*)goodRecoForm
{
    _touchedRecommendForm = goodRecoForm;
    [self performSegueWithIdentifier:@"segueToGoodsDetail" sender:self];
}


#pragma mark- storyboardSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToServiceDetail"])
    {
        CZJServiceListController* detailInfo = segue.destinationViewController;
        detailInfo.title = @"";
        detailInfo.navTitleName = @"";
        detailInfo.typeId = _serviceTypeId;
    }
    if ([segue.identifier isEqualToString:@"segueToGoodsDetail"])
    {
        CZJDetailViewController* detailVC = segue.destinationViewController;
        detailVC.storeItemPid = _touchedRecommendForm.storeItemPid;
        detailVC.detaiViewType = (([_touchedRecommendForm.itemType integerValue] == 1) ? CZJDetailTypeService : CZJDetailTypeGoods);
        detailVC.promotionType = CZJGoodsPromotionTypeGeneral;
        detailVC.promotionPrice = @"";
    }
    if ([segue.identifier isEqualToString:@"segueToMiaoSha"])
    {
    }
}

#pragma mark- IBAction
- (IBAction)tapToTop:(id)sender
{
    [self.homeTableView setContentOffset:CGPointMake(0,0) animated:YES];
}


- (void)showWebViewWithURL:(NSString*)url
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = url;
    [self.navigationController pushViewController:webView animated:YES];
}



#pragma mark -
#pragma mark -版本检测
- (void)checkTheLatestVersion {
    __weak typeof(self) weakSelft = self;
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        DLog(@"version:%@",[[CZJUtils DataFromJson:json] description]);
        versionForm = [CZJVersionForm objectWithKeyValues:[[CZJUtils DataFromJson:json]valueForKey:@"msg"]];
        [weakSelft checkUpdate:versionForm.versionNo];
        
        [CZJUtils writeDictionaryToDocumentsDirectory:[[CZJUtils DataFromJson:json]valueForKey:@"msg"] withPlistName:@"checkVersion.plist"];
    } fail:^{
        
    } andServerAPI:kCZJServerAPICheckVersion];
}

- (void)checkUpdate:(NSString *)versionFromAppStroe {
    
    //获取bundle里面关于当前版本的信息
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSLog(@"nowVersion == %@",nowVersion);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSString* messge = @"亲，版本已升级，请立即更新吧~";
    //检查当前版本版本号是否小于服务器的版本号，如果是，则更新
    if ([versionFromAppStroe integerValue]  > [nowVersion integerValue])
    {
        UIAlertView *createUserResponseAlert;
        if ([versionForm.enforce boolValue])
        {
            createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:messge delegate:self cancelButtonTitle:@"去AppStore下载" otherButtonTitles:nil];
        }
        else
        {
            createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:messge delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"去AppStore下载", nil];
        }
        [createUserResponseAlert show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        //是否需要强制更新
        if ([versionForm.enforce boolValue])
        {
            NSString* url = versionForm.url;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            [CZJUtils performBlock:^{
                exit(0);
            } afterDelay:0.5];
        }
    }
    else if (1 == buttonIndex)
    {
        NSString* url = versionForm.url;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
