//
//  CZJDetailInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceDetailInfo.h"
#import "CZJHomeViewManager.h"
#import "CZJStoreForm.h"
#import "FDAlertView.h"
#import "PullTableView.h"
#import "MXPullDownMenu.h"
#import "CZJStoreCell.h"
#import "UIImageView+WebCache.h"
#import "CCLocationManager.h"
#import "MGMineMenuVc.h"

@interface CZJServiceDetailInfo ()<
    UITableViewDataSource,
    UITableViewDelegate,
    PullTableViewDelegate,
    MXPullDownMenuDelegate
>
{
    NSMutableArray* _sortedStoreArys;
    NSMutableDictionary* storePostParams;
    CZJHomeGetDataFromServerType _getdataType;
    
    BOOL _isAnimate;
}
@property (weak, nonatomic) IBOutlet MXPullDownMenu *pullDownMenu;
@property (weak, nonatomic) IBOutlet PullTableView *serviceTableView;
@property (weak, nonatomic) IBOutlet UIView *refreshLocationBarView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (assign, nonatomic)NSInteger page;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIView *upView;
@end

@implementation CZJServiceDetailInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];
    
    [self initData];
    [self initTableViewAndPullDownMenu];
    [self getStoreServiceListDataFromServer];
    [self initRefreshLocationBarView];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect currentFrame = _refreshLocationBarView.frame;
    _refreshLocationBarView.frame = CGRectMake(30, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
    _locationButton.tag = CZJViewMoveOrientationLeft;
    [self btnTouched:nil];
    
    [_pullDownMenu registNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pullDownMenu removeNotificationObserve];
}


- (void)initData
{
    self.page = 1;
    storePostParams = [[NSMutableDictionary alloc]init];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    _refreshLocationBarView.layer.borderWidth = 1.5;
    _refreshLocationBarView.layer.borderColor = [UIColor redColor].CGColor;
    
    //参数初始化
    [storePostParams setObject:@"0" forKey:@"cityId"];
    [storePostParams setObject:@"0" forKey:@"storeType"];
    [storePostParams setObject:@"0" forKey:@"sortType"];
    [storePostParams setObject:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
}

- (void)initTableViewAndPullDownMenu
{
    //门店服务列表
    self.serviceTableView.pullDelegate = self;
    self.serviceTableView.dataSource = self;
    self.serviceTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINib *nib=[UINib nibWithNibName:@"CZJStoreCell" bundle:nil];
    [self.serviceTableView registerNib:nib forCellReuseIdentifier:@"CZJStoreCell"];
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"评分最高", @"销量最高"];
    NSArray* storeTypes = @[@"筛选"];
    if ([CZJHomeViewInstance storeForm].provinceForms &&
        [CZJHomeViewInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJHomeViewInstance storeForm].provinceForms, sortTypes,storeTypes];
        [self.pullDownMenu initWithArray:menuArray AndType:CZJMXPullDownMenuTypeService WithFrame:self.pullDownMenu.frame].delegate = self;
    }
}

- (void)getStoreServiceListDataFromServer
{
    DLog(@"storeparameters:%@", [storePostParams description]);
    CZJSuccessBlock successBlock = ^(id json) {
        [self dealWithArray];
        [self.serviceTableView reloadData];
        
        if (self.serviceTableView.pullTableIsRefreshing == YES)
        {
            self.serviceTableView.pullLastRefreshDate = [NSDate date];
        }
        self.serviceTableView.pullTableIsLoadingMore = NO;
        self.serviceTableView.pullTableIsRefreshing = NO;
    };
    
    [CZJHomeViewInstance showStoreWithParams:storePostParams
                                        type:_getdataType
                                     success:successBlock
                                        fail:^{}];
}

- (void)dealWithArray
{
    [_sortedStoreArys removeAllObjects];
    _sortedStoreArys = [[NSArray arrayWithArray:[CZJHomeViewInstance storeForm].storeListForms]mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- 定位功能区
- (void)initRefreshLocationBarView
{
    [self.view.window addSubview:_refreshLocationBarView];
    _locationButton.tag = CZJViewMoveOrientationLeft;
    [_locationButton addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self btnTouched:nil];
}

- (void)btnTouched:(id)sender
{
    if (CZJViewMoveOrientationLeft == _locationButton.tag)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveLocationBarViewOut) object:nil];
    }
    [self storeStartLocation];
}


- (void)storeStartLocation
{
    if (![[CCLocationManager shareLocation] isLocationEnable]) {
        self.locationNameLabel.text = @"亲，未开启定位功能哦~";
        return;
    }
    [self startSpin];
    [[CCLocationManager shareLocation] getAddress:^(NSString *addressString) {
        [self stopSpin];
        self.locationNameLabel.text = addressString;
        if (_locationButton.tag == CZJViewMoveOrientationRight)
        {
            [self performSelector:@selector(moveLocationBarViewIn) withObject:nil afterDelay:0.5];
        }
        if (_locationButton.tag == CZJViewMoveOrientationLeft)
        {
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:2.0];
        }
        
    }];
    [[CCLocationManager shareLocation] getCity:^(NSString *addressString) {
        NSString* cityid = [CZJHomeViewInstance.storeForm getCityIDWithCityName:addressString];
        [storePostParams setValue:cityid  forKey:@"cityId"];
        _getdataType = CZJHomeGetDataFromServerTypeOne;
        [self getStoreServiceListDataFromServer];
        if (nil != addressString)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJChangeCurCityName object:self userInfo:@{@"cityname" : addressString}];
        }
        
    }];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _locationButton.transform = CGAffineTransformRotate(_locationButton.transform, M_PI / 2);
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
            [_locationButton setTag:CZJViewMoveOrientationLeft];
            break;
        case CZJViewMoveOrientationRight:
            [_locationButton setTag:CZJViewMoveOrientationRight];
            originX = PJ_SCREEN_WIDTH - 40;
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.5 animations:^{
        _refreshLocationBarView.frame = CGRectMake(originX, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
    } completion:^(BOOL finished) {
        if (finished && CZJViewMoveOrientationLeft == orient)
        {
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:4.0];
        }
    }];
}


#pragma mark- PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
    self.page = 1;
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    _getdataType = CZJHomeGetDataFromServerTypeTwo;
    self.page++;
    [self getStoreServiceListDataFromServer];;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJStoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreCell" forIndexPath:indexPath];
    CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)_sortedStoreArys[indexPath.row];
    cell.storeName.text = storeForm.name;
    cell.dealCount.text = storeForm.purchaseCount;
    cell.storeDistance.text = storeForm.distance;
    cell.storeLocation.text = storeForm.addr;
    cell.feedbackRate.text = storeForm.star;
    [cell.storeCellImageView sd_setImageWithURL:[NSURL URLWithString:storeForm.homeImg] placeholderImage:nil];
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_sortedStoreArys.count > 0)
    {
        return 1;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cout = _sortedStoreArys.count;
    return cout;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
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
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    [storePostParams setValue:[CZJHomeViewInstance.storeForm getCityIDWithCityName:cityName]  forKey:@"cityId"];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}

- (void)pullDownMenuDidSelectFiliterButton
{
    [self actionBtn];
}

- (void)actionBtn{
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    
    [window makeKeyAndVisible];
    MGMineMenuVc *up = [[MGMineMenuVc alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:up];
    up.view.frame = window.bounds;
    window.rootViewController = nav;
    self.window = window;
    
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc]initWithFrame:self.view.bounds];
    UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [effectView setEffect:effect];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [effectView addGestureRecognizer:tap];
    [self.view addSubview:effectView];
    self.upView = effectView;
    
    __weak typeof(self) weak = self;
    [up setCancleBarItemHandle:^{
        [weak.upView removeFromSuperview];
        [weak.window resignKeyWindow];
        weak.window  = nil;
        weak.upView = nil;
    }];
    
}

- (void)tapAction{
    [self.upView removeFromSuperview];
    [self.window resignKeyWindow];
    self.window  = nil;
    self.upView = nil;
}

@end
