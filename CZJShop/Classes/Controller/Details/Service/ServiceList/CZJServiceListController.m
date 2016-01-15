//
//  CZJDetailInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceListController.h"
#import "CZJBaseDataManager.h"
#import "CZJNaviagtionBarView.h"
#import "CZJStoreForm.h"
#import "FDAlertView.h"
#import "PullTableView.h"
#import "MXPullDownMenu.h"
#import "CZJStoreCell.h"
#import "CZJStoreServiceCell.h"
#import "UIImageView+WebCache.h"
#import "CCLocationManager.h"
#import "CZJServiceFilterController.h"
#import "CZJDetailViewController.h"

@interface CZJServiceListController ()<
    UITableViewDataSource,
    UITableViewDelegate,
    PullTableViewDelegate,
    MXPullDownMenuDelegate,
    CZJNaviagtionBarViewDelegate,
    CZJFilterControllerDelegate
>
{
    NSMutableArray* _sortedStoreArys;
    NSMutableDictionary* storePostParams;
    CZJHomeGetDataFromServerType _getdataType;
    
    BOOL _isAnimate;
    float lastY;
}
@property (weak, nonatomic) IBOutlet MXPullDownMenu *pullDownMenu;
@property (weak, nonatomic) IBOutlet PullTableView *serviceTableView;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *refreshLocationBarView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


@property (assign, nonatomic)NSInteger page;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIView *upView;
@end

@implementation CZJServiceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];
    
    isFirstIn = YES;
    [self initData];
    [self initTableViewAndPullDownMenu];
    [self initRefreshLocationBarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [_navigationBar refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isFirstIn) {
        CGRect currentFrame = _refreshLocationBarView.frame;
        _refreshLocationBarView.frame = CGRectMake(30, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
        _locationButton.tag = CZJViewMoveOrientationLeft;
        [self btnTouched:nil];
        isFirstIn = NO;
    }
    
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
    [storePostParams setObject:@"" forKey:@"modelId"];
    [storePostParams setObject:_typeId forKey:@"typeId"];
    [storePostParams setObject:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
}

- (void)initTableViewAndPullDownMenu
{
    //门店服务列表
    self.serviceTableView.pullDelegate = self;
    self.serviceTableView.dataSource = self;
    self.serviceTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.serviceTableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib=[UINib nibWithNibName:@"CZJStoreCell" bundle:nil];
    [self.serviceTableView registerNib:nib forCellReuseIdentifier:@"CZJStoreCell"];
    UINib *nib2=[UINib nibWithNibName:@"CZJStoreServiceCell" bundle:nil];
    [self.serviceTableView registerNib:nib2 forCellReuseIdentifier:@"CZJStoreServiceCell"];
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"评分最高", @"销量最高"];
    NSArray* storeTypes = @[@"筛选"];
    if ([CZJBaseDataInstance storeForm].provinceForms &&
        [CZJBaseDataInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJBaseDataInstance storeForm].provinceForms, sortTypes,storeTypes];
        [self.pullDownMenu initWithArray:menuArray AndType:CZJMXPullDownMenuTypeService WithFrame:self.pullDownMenu.frame].delegate = self;
    }
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    [self.navigationBar initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeBack].delegate = self;
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
    
    [CZJBaseDataInstance showSeverciceList:storePostParams
                                      type:_getdataType
                                   success:successBlock
                                      fail:^{}];
}

- (void)dealWithArray
{
    [_sortedStoreArys removeAllObjects];
    _sortedStoreArys = [[NSArray arrayWithArray:[CZJBaseDataInstance storeForm].storeServiceListForms]mutableCopy];
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
        NSString* cityid = [CZJBaseDataInstance.storeForm getCityIDWithCityName:addressString];
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
    
    float contentOffsetY = [scrollView contentOffset].y;
    
    DLog(@"%f",contentOffsetY - lastY);
//    CGRect rect = _pullDownMenu.frame;
//    if (rect.origin.y <= 20 || (contentOffsetY - lastY) > 0) {
//        _pullDownMenu.frame = CGRectMake(rect.origin.x, rect.origin.y - contentOffsetY + lastY, rect.size.width, rect.size.height);
//    }
    lastY = contentOffsetY;
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        CZJStoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreCell"];
        CZJNearbyStoreServiceListForm* storeForm = (CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.storeName.text = storeForm.name;
        cell.dealCount.text = storeForm.purchaseCount;
        cell.storeDistance.text = storeForm.distance;
        cell.storeLocation.text = storeForm.addr;
        cell.feedbackRate.text = storeForm.star;
        [cell.storeCellImageView sd_setImageWithURL:[NSURL URLWithString:storeForm.homeImg] placeholderImage:nil];
        return cell;
    }
    else if ((((CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section]).items.count + 1) == indexPath.row)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMoreCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CZJMoreCell"];
            UILabel* moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH*0.5 - 50, 14, 100, 21)];
            moreLabel.text = @"查看更多服务";
            moreLabel.textColor = [UIColor lightGrayColor];
            moreLabel.font = [UIFont systemFontOfSize:15];
            moreLabel.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:moreLabel];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        CZJStoreServiceCell* cell  = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreServiceCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CZJStoreServiceForm* storeForm = ((CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section]).items[indexPath.row - 1];
        cell.serviceItemName.text = storeForm.itemName;
        NSString* rmbCharater = @"￥";
        cell.currentPrice.text = [rmbCharater stringByAppendingString:storeForm.currentPrice];
        cell.purchasedCount.text = storeForm.purchaseCount;
        NSString* orginPrice = [rmbCharater stringByAppendingString:storeForm.originalPrice];
        [cell.originPrice setAttributedText:[CZJUtils stringWithDeleteLine:orginPrice]];
        return cell;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger cout = _sortedStoreArys.count;
    
    return cout;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cout = ((CZJNearbyStoreServiceListForm*)_sortedStoreArys[section]).items.count;
    if (cout > 0)
    {
        cout = cout + 2;
    }
    return cout;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
    {
        return 104;
    }
    else if ((((CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section]).items.count + 1) == indexPath.row)
    {
        return 50;
    }
    else
    {
        return 70;
    }
    return 94;
}


- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    self.serviceTableView.tintColor = RGBA(230, 230, 230, 1.0f);
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 14;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {//门店详情
        
    }
    else if ((((CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section]).items.count + 1) == indexPath.row)
    {//查看更多服务
        
    }
    else
    {//服务详情
        CZJStoreServiceForm* serviceForm = ((CZJNearbyStoreServiceListForm*)_sortedStoreArys[indexPath.section]).items[indexPath.row - 1];
        _choosedStoreitemPid = serviceForm.storeItemPid;
        [self performSegueWithIdentifier:@"segueToServiceDetail" sender:self];
    }

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
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    [storePostParams setValue:[CZJBaseDataInstance.storeForm getCityIDWithCityName:cityName]  forKey:@"cityId"];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}

- (void)pullDownMenuDidSelectFiliterButton
{
    [self actionBtn];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)actionBtn{
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    [window makeKeyAndVisible];
    
    CZJServiceFilterController *serviceFilterController = [[CZJServiceFilterController alloc] init];
    serviceFilterController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:serviceFilterController];
    serviceFilterController.view.frame = window.bounds;
    window.rootViewController = nav;
    self.window = window;
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
    self.upView = view;
    self.upView.alpha = 0.0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.window.frame = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.upView.alpha = 1.0;
    } completion:nil];
    
    
    __weak typeof(self) weak = self;
    [serviceFilterController setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
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

- (void)tapAction{
    [UIView animateWithDuration:0.5 animations:^{
        self.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
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

#pragma mark -CZJServiceFilterDelegate
- (void)chooseFilterOK
{
    //更新参数，重新请求数据刷新
    NSString* typeid = [USER_DEFAULT valueForKey:kUserDefaultServiceTypeID];
    [storePostParams setValue:typeid forKey:@"typeId"];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreServiceListDataFromServer];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToServiceDetail"])
    {
        CZJDetailViewController* serviceDetailCon = segue.destinationViewController;
        serviceDetailCon.storeItemPid = _choosedStoreitemPid;
        serviceDetailCon.detaiViewType = CZJDetailTypeService;
    }
}

@end
