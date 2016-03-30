//
//  CZJStoreViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/3/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJStoreViewController.h"
#import "CZJBaseDataManager.h"
#import "CZJStoreForm.h"
#import "PullTableView.h"
#import "MXPullDownMenu.h"
#import "CZJStoreCell.h"
#import "CCLocationManager.h"
#import "CZJStoreDetailController.h"

@interface CZJStoreViewController ()
<
PullTableViewDelegate,
MXPullDownMenuDelegate,
CZJNaviagtionBarViewDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* _storeArys;
    NSMutableArray* _sortedStoreArys;
    NSMutableDictionary* storePostParams;
    CZJHomeGetDataFromServerType _getdataType;
    BOOL _isAnimate;
    
    NSString* storeType;
    NSString* sortType;
}


@property (weak, nonatomic) IBOutlet MXPullDownMenu *pullDownMenu;
@property (weak, nonatomic) IBOutlet PullTableView *storeTableView;
@property (weak, nonatomic) IBOutlet UIView *refreshLocationBarView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic,retain)NSString* curLocationCityName;
@property (assign, nonatomic)NSInteger page;

@end

@implementation CZJStoreViewController
@synthesize curLocationCityName = _curLocationCityName;
@synthesize page = _page;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self dealWithTableView];
    [self getStoreDataFromServer];
    [self initRefreshLocationBarView];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect currentFrame = _refreshLocationBarView.frame;
    _refreshLocationBarView.frame = CGRectMake(30, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
    _locationButton.tag = CZJViewMoveOrientationLeft;
    self.navigationController.interactivePopGestureRecognizer.enabled = true;
    [_pullDownMenu registNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_pullDownMenu removeNotificationObserve];
}

- (void)initDatas
{
    //变量数据初始
    self.page = 1;
    storePostParams = [[NSMutableDictionary alloc]init];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    _refreshLocationBarView.layer.borderWidth = 1.5;
    _refreshLocationBarView.layer.borderColor = CZJREDCOLOR.CGColor;
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"评分最高", @"销量最高"];
    NSArray* storeTypes = @[@"全部",@"一站式", @"快修快保", @"装饰美容" , @"维修厂"];
    if ([CZJBaseDataInstance storeForm].provinceForms &&
        [CZJBaseDataInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJBaseDataInstance storeForm].provinceForms, sortTypes,storeTypes];
        [self.pullDownMenu initWithArray:menuArray AndType:CZJMXPullDownMenuTypeStore WithFrame:self.pullDownMenu.frame].delegate = self;
    }
    
    //参数初始化
    if (self.searchStr)
    {
        [storePostParams setObject:self.searchStr forKey:@"q"];
    }

    [storePostParams setObject:@"0" forKey:@"cityId"];
    [storePostParams setObject:@"0" forKey:@"storeType"];
    [storePostParams setObject:@"0" forKey:@"sortType"];
    [storePostParams setObject:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
}


- (void)dealWithTableView
{
    self.storeTableView.pullDelegate = self;
    self.storeTableView.dataSource = self;
    self.storeTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeTableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib=[UINib nibWithNibName:@"CZJStoreCell" bundle:nil];
    [self.storeTableView registerNib:nib forCellReuseIdentifier:@"CZJStoreCell"];
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeMain];
    self.naviBarView.mainTitleLabel.text = @"门店";
}

- (void)getStoreDataFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CZJSuccessBlock successBlock = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self dealWithArray];
        [self.storeTableView reloadData];
        
        if (self.storeTableView.pullTableIsRefreshing == YES)
        {
            self.storeTableView.pullLastRefreshDate = [NSDate date];
        }
        self.storeTableView.pullTableIsLoadingMore = NO;
        self.storeTableView.pullTableIsRefreshing = NO;
    };

    CZJFailureBlock failBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getStoreDataFromServer];
        }];
    };
    [CZJBaseDataInstance showStoreWithParams:storePostParams
                                        type:_getdataType
                                     success:successBlock
                                        fail:failBlock];
}

- (void)dealWithArray
{
    [_sortedStoreArys removeAllObjects];
    _sortedStoreArys = [[NSArray arrayWithArray:[CZJBaseDataInstance storeForm].storeListForms]mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark- 定位功能区
- (void)initRefreshLocationBarView
{
    [self.window addSubview:_refreshLocationBarView];
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
        [self getStoreDataFromServer];
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
    [self getStoreDataFromServer];
    self.page = 1;
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    _getdataType = CZJHomeGetDataFromServerTypeTwo;
    self.page++;
    [self getStoreDataFromServer];;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK;
    CZJStoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreCell" forIndexPath:indexPath];
    CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)_sortedStoreArys[indexPath.row];
    cell.storeName.text = storeForm.name;
    cell.dealCount.text = storeForm.purchaseCount;
    cell.storeDistance.text = storeForm.distance;
    cell.storeLocation.text = storeForm.addr;
    cell.feedbackRate.text = storeForm.evaluationAvg;
    cell.purchaseCountWidth.constant = [CZJUtils calculateTitleSizeWithString:storeForm.purchaseCount AndFontSize:14].width + 5;
    cell.imageOne.hidden = YES;
    cell.imageTwo.hidden = YES;
    [cell.storeCellImageView sd_setImageWithURL:[NSURL URLWithString:storeForm.homeImg] placeholderImage:DefaultPlaceHolderImage];
    
    if (storeForm.promotionFlag && !storeForm.couponFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_cu")];
    }
    if (!storeForm.promotionFlag && storeForm.couponFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_quan")];
    }
    if (storeForm.promotionFlag && storeForm.couponFlag)
    {
        cell.imageOne.hidden = NO;
        cell.imageTwo.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_cu")];
        [cell.imageTwo setImage:IMAGENAMED(@"label_icon_quan")];
    }
    TOCK;
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

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)_sortedStoreArys[indexPath.row];
    [self performSegueWithIdentifier:@"segueToStoreDetail" sender:storeForm];
}

#pragma mark -  MXPullDownMenuDelegate
- (void)PullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row
{
    if (1 == column)
    {
        sortType = [NSString stringWithFormat:@"%ld", row];
        [storePostParams setValue:sortType forKey:@"sortType"];
    }
    if (2 == column)
    {
        storeType = [NSString stringWithFormat:@"%ld", row];
        [storePostParams setValue:storeType forKey:@"storeType"];
    }
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    [storePostParams setValue:[CZJBaseDataInstance.storeForm getCityIDWithCityName:cityName]  forKey:@"cityId"];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreDataFromServer];
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    [self performSegueWithIdentifier:@"segueToNearby" sender:nil];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToStoreDetail"])
    {
        CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)sender;
        CZJStoreDetailController* storeDetail = segue.destinationViewController;
        storeDetail.storeId = storeForm.storeId;
    }
}


@end
