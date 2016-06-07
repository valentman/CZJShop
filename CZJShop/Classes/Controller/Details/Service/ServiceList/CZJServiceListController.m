//
//  CZJDetailInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceListController.h"
#import "CZJBaseDataManager.h"
#import "CZJStoreForm.h"
#import "MXPullDownMenu.h"
#import "CZJStoreCell.h"
#import "CZJStoreServiceCell.h"
#import "CCLocationManager.h"
#import "ZXLocationManager.h"
#import "CZJServiceFilterController.h"
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"
#import "CZJRefreshLocationBarView.h"

@interface CZJServiceListController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIGestureRecognizerDelegate,
    MXPullDownMenuDelegate,
    CZJNaviagtionBarViewDelegate,
    CZJFilterControllerDelegate
>
{
    NSMutableArray* _serviceListArys;
    __block CZJHomeGetDataFromServerType _getdataType;
    
    CGPoint pullDownMenuOriginPoint;        //下拉列表区原始位置
    CGPoint naviBraviewOriginPoint;         //导航栏原始位置
    
    BOOL _isAnimate;
    BOOL _isTouch;
    float lastContentOffsetY;
    
    MXPullDownMenu* _pullDownMenu;
    MJRefreshAutoNormalFooter* refreshFooter;
    
    NSString* cityID;           //城市ID
    NSString* sortType;         //排序
    NSString* modelId;          //车型
    NSString* goHouseFlag;           //上门服务
    NSString* goStoreFlag;           //到店服务
    
}
@property (strong, nonatomic) UITableView *serviceTableView;
@property (strong, nonatomic) CZJRefreshLocationBarView *refreshLocationBarView;
@property (assign, nonatomic)NSInteger page;
@end

@implementation CZJServiceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initTableViewAndPullDownMenu];
    [self initRefreshLocationBarView];
    [self getStoreServiceListDataFromServer];
}

- (void)initData
{
    isFirstIn = YES;
    _serviceListArys = [NSMutableArray array];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    
    //参数初始化
    cityID = CZJBaseDataInstance.userInfoForm.cityId;
    sortType = @"0";
    modelId = @"";
    goStoreFlag = @"0";
    goHouseFlag = @"0";
    self.page = 1;
}

- (void)initTableViewAndPullDownMenu
{
    self.serviceTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110) style:UITableViewStylePlain];
    self.serviceTableView.tableFooterView = [[UIView alloc]init];
    self.serviceTableView.delegate = self;
    self.serviceTableView.dataSource = self;
    self.serviceTableView.clipsToBounds = NO;
    self.serviceTableView.showsVerticalScrollIndicator = NO;
    self.serviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.serviceTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.serviceTableView];
    //门店服务列表
    UINib *nib2=[UINib nibWithNibName:@"CZJStoreServiceCell" bundle:nil];
    [self.serviceTableView registerNib:nib2 forCellReuseIdentifier:@"CZJStoreServiceCell"];
    
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeBack];
    self.naviBarView.detailType = CZJDetailTypeService;
    self.naviBarView.buttomSeparator.hidden = YES;
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"价格最低", @"价格最高", @"评论最多", @"销量最高"];
    NSArray* storeTypes = @[@"筛选"];
    if ([CZJBaseDataInstance storeForm].provinceForms &&
        [CZJBaseDataInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJBaseDataInstance storeForm].provinceForms, sortTypes,storeTypes];
        _pullDownMenu  = [[MXPullDownMenu alloc]initWithArray:menuArray AndType:CZJMXPullDownMenuTypeService WithFrame:CGRectMake(0, 200, PJ_SCREEN_WIDTH, 46)];
        _pullDownMenu.delegate = self;
        _pullDownMenu.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
        [self.view addSubview:_pullDownMenu];
    }
}

- (void)initRefreshLocationBarView
{
    _refreshLocationBarView = [CZJUtils getXibViewByName:@"CZJRefreshLocationBarView"];
    _refreshLocationBarView.frame = CGRectMake(PJ_SCREEN_WIDTH - 35, PJ_SCREEN_HEIGHT - 35, PJ_SCREEN_WIDTH + 35, 35);
    [_refreshLocationBarView setPosition:CGPointMake(PJ_SCREEN_WIDTH - 35, PJ_SCREEN_HEIGHT - 35) atAnchorPoint:CGPointLeftMiddle];
    [self.view addSubview:_refreshLocationBarView];
    [self.view bringSubviewToFront:_refreshLocationBarView];
    _refreshLocationBarView.locationButton.tag = CZJViewMoveOrientationLeft;
    [_refreshLocationBarView.locationButton addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [_pullDownMenu registNotification];

    if ([USER_DEFAULT objectForKey:CCLastCity])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJChangeCurCityName object:self userInfo:@{@"cityname" : [CZJUtils isBlankString:[USER_DEFAULT objectForKey:CCLastCity]] ? @"全部地区" : [USER_DEFAULT objectForKey:CCLastCity]}];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [self.naviBarView refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    //获取导航栏和下拉栏原始位置，为了上拉或下拉时动画
    pullDownMenuOriginPoint = _pullDownMenu.frame.origin;
    naviBraviewOriginPoint = self.naviBarView.frame.origin;
    [[UIApplication sharedApplication]setStatusBarHidden:(self.naviBarView.frame.origin.y < 0) withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_pullDownMenu removeNotificationObserve];
}

- (void)getStoreServiceListDataFromServer
{
    
    NSDictionary* storePostParams = @{@"modelId" :modelId, @"typeId" :self.typeId, @"sortType" :sortType, @"q" :self.searchStr ? self.searchStr : @"", @"goHouseFlag":goHouseFlag ,@"goStoreFlag":goStoreFlag, @"page" : [NSString stringWithFormat:@"%ld",(long)self.page]};
    
    __weak typeof(self) weak = self;
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    if (_getdataType == CZJHomeGetDataFromServerTypeOne)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    CZJSuccessBlock successBlock = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:weak.view animated:NO];
        
        //返回数据回来还未解析到本地数组中时就添加下拉刷新footer
        if (_serviceListArys.count == 0)
        {
            refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
                _getdataType = CZJHomeGetDataFromServerTypeTwo;
                weak.page++;
                [weak getStoreServiceListDataFromServer];;
            }];
            weak.serviceTableView.footer = refreshFooter;
            weak.serviceTableView.footer.hidden = YES;
        }
        else
        {
            weak.serviceTableView.footer.hidden = NO;
        }
        [weak.serviceTableView.footer endRefreshing];
        
        //解析返回的数据
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (_getdataType == CZJHomeGetDataFromServerTypeTwo)
        {//如果是下拉刷新类型添加返回数据到当前数组中
            NSArray* tmpAry = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
            if (tmpAry.count > 0)
            {
                [_serviceListArys addObjectsFromArray:tmpAry];
                [weak.serviceTableView reloadData];
            }
            else
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        else
        {//如果是第一次进入数据请求
            _serviceListArys = [[CZJStoreServiceForm objectArrayWithKeyValuesArray:dict] mutableCopy];
            if (_serviceListArys.count == 0)
            {
                [CZJUtils showNoDataAlertViewOnTarget:weak.view withPromptString:@"木有该类服务/(ToT)/~~"];
            }
            
            if (_getdataType == CZJHomeGetDataFromServerTypeOne)
            {
                [weak.serviceTableView setContentOffset:CGPointMake(0,0) animated:NO];
            }
            [weak.serviceTableView reloadData];
            weak.serviceTableView.footer.hidden = weak.serviceTableView.mj_contentH < weak.serviceTableView.frame.size.height;
        }
    };
    
    [CZJBaseDataInstance generalPost:storePostParams success:successBlock  fail:^{
        [MBProgressHUD hideAllHUDsForView:weak.view animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            _getdataType = CZJHomeGetDataFromServerTypeOne;
            weak.page = 1;
            [weak getStoreServiceListDataFromServer];
        }];
    } andServerAPI:kCZJServerAPIGetServiceList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJStoreServiceCell* cell  = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreServiceCell"];
    CZJStoreServiceForm* storeForm = _serviceListArys[indexPath.row];
    
    [cell.serviceImg sd_setImageWithURL:[NSURL URLWithString:storeForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    cell.storeName.text = storeForm.storeName;
    cell.distance.text = storeForm.distance;
    cell.serviceItemName.text = storeForm.itemName;
    NSString* currentPrice = [NSString stringWithFormat:@"￥%@",storeForm.currentPrice];
    cell.currentPrice.keyWordFont = SYSTEMFONT(12);
    cell.currentPrice.text = currentPrice;
    cell.currentPrice.keyWord = @"￥";
    cell.priceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:currentPrice AndFontSize:15].width + 5;
    cell.goodRate.text = storeForm.goodEvalRate;
    cell.purchasedCount.text = storeForm.evalCount;
    cell.purchasedCountWidth.constant = [CZJUtils calculateTitleSizeWithString:storeForm.evalCount AndFontSize:12].width + 5;
    cell.serviceTypeImg.hidden = !storeForm.goStoreFlag;
    
    cell.imageOne.hidden = YES;
    cell.imageTwo.hidden = YES;
    if (storeForm.newlyFlag && !storeForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_new")];
    }
    else if (!storeForm.newlyFlag && storeForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_cu")];
    }
    else if (storeForm.newlyFlag && storeForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        cell.imageTwo.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_new")];
        [cell.imageTwo setImage:IMAGENAMED(@"label_icon_cu")];
    }
    cell.separatorInset = HiddenCellSeparator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _serviceListArys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 126;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    self.serviceTableView.tintColor = RGBA(230, 230, 230, 1.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJStoreServiceForm* serviceForm = _serviceListArys[indexPath.row];
    _choosedStoreitemPid = serviceForm.storeItemPid;
    [self performSegueWithIdentifier:@"segueToServiceDetail" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    
    //判断是否是上拉（isDraggingDown = false）还是下滑（isDraggingDown = true）
    bool isDraggingDown = (lastContentOffsetY - contentOffsetY) > 0 ;
    lastContentOffsetY = contentOffsetY;
    if (UIGestureRecognizerStateChanged == scrollView.panGestureRecognizer.state)
    {
        if (isDraggingDown &&
            self.naviBarView.frame.origin.y < 0 &&
            _isTouch)
        {
            _isTouch = NO;
            DLog(@"下拉");
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.naviBarView.frame = CGRectMake(0, 20, PJ_SCREEN_WIDTH, 44);
                _pullDownMenu.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
                self.serviceTableView.frame = CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110);
            } completion:nil];
        }
        else if (!isDraggingDown &&
                 _pullDownMenu.frame.origin.y > 0 &&
                 _isTouch)
        {
            if (self.serviceTableView.mj_contentH < self.serviceTableView.frame.size.height)
            {//如果返回的内容都没超过一个屏幕的高度，上拉下滑移动导航栏就没意义
                return;
            }
            _isTouch = NO;
            DLog(@"上拉");
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.naviBarView.frame = CGRectMake(0, -110, PJ_SCREEN_WIDTH, 44);
                _pullDownMenu.frame = CGRectMake(0, -46, PJ_SCREEN_WIDTH, 46);
                self.serviceTableView.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
            } completion:nil];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isTouch = YES;
    DLog();
}

#pragma mark- 定位功能区
- (void)btnTouched:(id)sender
{
    if (CZJViewMoveOrientationLeft == _refreshLocationBarView.locationButton.tag)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveLocationBarViewOut) object:nil];
    }
    [self storeStartLocation];
}


- (void)storeStartLocation
{
    [self justLocation];
    [self getCityNameWithLocation];
}

- (void)justLocation
{
    if (IS_IOS8) {
        if (![[CCLocationManager shareLocation] isLocationEnable]) {
            _refreshLocationBarView.locationNameLabel.text = @"亲，未开启定位功能哦~";
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationRight)
            {
                [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
            }
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationLeft)
            {
                [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.0];
            }
            return;
        }
        [self startSpin];
        [[CCLocationManager shareLocation] getAddress:^(NSString *addressString) {
            [self stopSpin];
            _refreshLocationBarView.locationNameLabel.text = addressString;
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationRight)
            {
                [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
            }
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationLeft)
            {
                [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.0];
            }
            
        }];
    }
    else if (IS_IOS7)
    {
        if (![[ZXLocationManager sharedZXLocationManager] isLocationEnable]) {
            _refreshLocationBarView.locationNameLabel.text = @"亲，未开启定位功能哦~";
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationRight)
            {
                [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
            }
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationLeft)
            {
                [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.0];
            }
            return;
        }
        [self startSpin];
        [[ZXLocationManager sharedZXLocationManager] getAddress:^(NSString *addressString) {
            [self stopSpin];
            _refreshLocationBarView.locationNameLabel.text = addressString;
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationRight)
            {
                [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
            }
            if (_refreshLocationBarView.locationButton.tag == CZJViewMoveOrientationLeft)
            {
                [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.0];
            }
            
        }];
    }
}

- (void)getCityNameWithLocation
{
    if (IS_IOS8) {
        [[CCLocationManager shareLocation] getCity:^(NSString *addressString) {
            cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:addressString];
            _getdataType = CZJHomeGetDataFromServerTypeOne;
            self.page = 1;
            [self getStoreServiceListDataFromServer];
            if (nil != addressString)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:kCZJChangeCurCityName object:self userInfo:@{@"cityname" : addressString}];
            }
            
        }];
    }
    else if (IS_IOS7)
    {
        [[ZXLocationManager sharedZXLocationManager] getCityName:^(NSString *addressString) {
            cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:addressString];
            _getdataType = CZJHomeGetDataFromServerTypeOne;
            self.page = 1;
            [self getStoreServiceListDataFromServer];
            if (nil != addressString)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:kCZJChangeCurCityName object:self userInfo:@{@"cityname" : addressString}];
            }
        }];
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _refreshLocationBarView.locationButton.transform = CGAffineTransformRotate(_refreshLocationBarView.locationButton.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (_isAnimate) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!_isAnimate) {
        _isAnimate = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    _isAnimate = NO;
}

- (void)moveLocationBarViewOut
{
    [self moveLocationBarViewWithOrient:CZJViewMoveOrientationRight];
}

- (void)moveLocationBarViewIn
{
    [self moveLocationBarViewWithOrient:CZJViewMoveOrientationLeft];
}

- (void)moveLocationBarViewWithOrient:(CZJViewMoveOrientation)orient
{
    CGRect currentFrame = _refreshLocationBarView.frame;
    CGFloat originX;
    switch (orient) {
        case CZJViewMoveOrientationLeft:
            originX = 30;
            [_refreshLocationBarView.locationButton setTag:CZJViewMoveOrientationLeft];
            break;
        case CZJViewMoveOrientationRight:
            [_refreshLocationBarView.locationButton setTag:CZJViewMoveOrientationRight];
            originX = PJ_SCREEN_WIDTH - 35;
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.5 animations:^{
        _refreshLocationBarView.frame = CGRectMake(originX, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
    } completion:^(BOOL finished) {
        if (finished && CZJViewMoveOrientationLeft == orient)
        {
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.5];
        }
    }];
}


#pragma mark- CZJNavigationBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    UIButton* _btn = (UIButton*)sender;
    DLog(@"bar touched");
    if (_btn.tag == CZJButtonTypeNaviBarBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -  MXPullDownMenuDelegate
- (void)PullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row
{
    if (1 == column)
    {
    }
    if (2 == column)
    {
    }
    
    DLog(@"%ld, %ld",column, row);
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    sortType = [NSString stringWithFormat:@"%ld",row];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    self.page = 1;
    [self getStoreServiceListDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    //根据城市名称
    cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:cityName];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    self.page = 1;
    [self getStoreServiceListDataFromServer];
}

- (void)pullDownMenuDidSelectFiliterButton:(MXPullDownMenu*)pullDownMenu
{
    [self actionBtn];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)actionBtn{
    __weak typeof(self) weakSelf = self;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    [window makeKeyAndVisible];
    
    CZJServiceFilterController *serviceFilterController = [[CZJServiceFilterController alloc] init];
    serviceFilterController.typeId = self.typeId;
    serviceFilterController.delegate = self;
    //传入取消回调
    [serviceFilterController setCancleBarItemHandle:^{
        [weakSelf tapAction];
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:serviceFilterController];
    serviceFilterController.view.frame = window.bounds;
    window.rootViewController = nav;
    self.window = window;
    
    //初始化upView
    self.upView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.upView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.upView.alpha = 0.0;
    //点击隐藏手势、侧滑隐藏手势
    [self.upView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    [self.upView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    //将upView添加到当前View上
    [self.view addSubview:self.upView];

    //开始执行出场动画
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.window.frame = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        weakSelf.upView.alpha = 1.0;
    } completion:nil];
}

- (void)tapAction{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        weakSelf.upView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.upView removeFromSuperview];
            [weakSelf.window resignKeyWindow];
            //获取弹出Window上的筛选控制器，移除控制器中得通知监听
            CZJServiceFilterController* serviceFilter = (CZJServiceFilterController*)[CZJUtils getViewControllerInUINavigator:(UINavigationController*)weakSelf.window.rootViewController withClass:[CZJServiceFilterController class]];
            if (serviceFilter)
            {
                [serviceFilter removeServiceFilterNotification];
            }
            weakSelf.window  = nil;
            weakSelf.upView = nil;
            weakSelf.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }];
}

#pragma mark -CZJServiceFilterDelegate
- (void)chooseFilterOK:(id)data
{
    //更新参数，重新请求数据刷新
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    modelId = [USER_DEFAULT valueForKeyPath:kUserDefaultChoosedCarModelID];
    goHouseFlag = @"";
    goStoreFlag = @"";
    self.typeId = [USER_DEFAULT valueForKey:kUserDefaultServiceTypeID];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    self.page = 1;
    [self getStoreServiceListDataFromServer];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToServiceDetail"])
    {
        CZJDetailViewController* serviceDetailCon = segue.destinationViewController;
        serviceDetailCon.storeItemPid = _choosedStoreitemPid;
        serviceDetailCon.detaiViewType = CZJDetailTypeService;
        serviceDetailCon.promotionPrice = @"0";
        serviceDetailCon.promotionType = CZJGoodsPromotionTypeGeneral;
    }
}


@end
