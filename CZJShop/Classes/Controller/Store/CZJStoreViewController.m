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
#import "CZJRefreshLocationBarView.h"

@interface CZJStoreViewController ()
<
MXPullDownMenuDelegate,
CZJNaviagtionBarViewDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* _storeArys;
    NSMutableArray* _sortedStoreArys;
    CZJHomeGetDataFromServerType _getdataType;
    MJRefreshAutoNormalFooter* refreshFooter;
    BOOL _isAnimate;
    BOOL isFirstIn;
    
    NSString* storeType;
    NSString* sortType;
    NSString* cityID;
}


@property (weak, nonatomic) IBOutlet MXPullDownMenu *pullDownMenu;
@property (weak, nonatomic) IBOutlet UITableView *storeTableView;
@property (strong, nonatomic) CZJRefreshLocationBarView *refreshLocationBarView;

@property (assign, nonatomic)NSInteger page;

@end

@implementation CZJStoreViewController
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
    //定位刷新栏,初始显示页面时执行弹出动画
    __weak typeof(self) weak = self;
    if (isFirstIn) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_refreshLocationBarView setPosition:CGPointMake(30, PJ_SCREEN_HEIGHT - 85) atAnchorPoint:CGPointLeftMiddle];
            _refreshLocationBarView.locationButton.tag = CZJViewMoveOrientationLeft;
        } completion:^(BOOL finished) {
            [weak btnTouched:nil];
        }];
        isFirstIn = NO;
    }
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
    isFirstIn = YES;
    self.page = 1;
    cityID = CZJBaseDataInstance.userInfoForm.cityId;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    storeType = @"0";
    sortType = @"0";
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"默认排序", @"距离最近", @"评分最高", @"销量最高"];
    NSArray* storeTypes = @[@"全部",@"一站式", @"快修快保", @"装饰美容" , @"维修厂"];
    if ([CZJBaseDataInstance storeForm].provinceForms &&
        [CZJBaseDataInstance storeForm].provinceForms.count > 0) {
        NSArray* menuArray = @[[CZJBaseDataInstance storeForm].provinceForms, sortTypes,storeTypes];
        [self.pullDownMenu initWithArray:menuArray AndType:CZJMXPullDownMenuTypeStore WithFrame:self.pullDownMenu.frame].delegate = self;
    }
}


- (void)dealWithTableView
{
    self.storeTableView.dataSource = self;
    self.storeTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeTableView.tableFooterView = [[UIView alloc] init];
    UINib *nib=[UINib nibWithNibName:@"CZJStoreCell" bundle:nil];
    [self.storeTableView registerNib:nib forCellReuseIdentifier:@"CZJStoreCell"];
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        weak.page++;
        [weak getStoreDataFromServer];;
    }];
    weak.storeTableView.footer = refreshFooter;
    weak.storeTableView.footer.hidden = YES;
    
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeMain];
    self.naviBarView.btnBack.hidden = (self.searchStr == nil);
    self.naviBarView.btnMore.hidden = !(self.searchStr == nil);
    self.naviBarView.mainTitleLabel.text = @"门店";
}

- (void)initRefreshLocationBarView
{
    _refreshLocationBarView = [CZJUtils getXibViewByName:@"CZJRefreshLocationBarView"];
    _refreshLocationBarView.frame = CGRectMake(PJ_SCREEN_WIDTH - 50, PJ_SCREEN_HEIGHT - 85, PJ_SCREEN_WIDTH + 50, 35);
    [_refreshLocationBarView setPosition:CGPointMake(PJ_SCREEN_WIDTH - 50, PJ_SCREEN_HEIGHT - 85) atAnchorPoint:CGPointLeftMiddle];
    [self.view addSubview:_refreshLocationBarView];
    [self.view bringSubviewToFront:_refreshLocationBarView];
    _refreshLocationBarView.locationButton.tag = CZJViewMoveOrientationLeft;
    [_refreshLocationBarView.locationButton addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)getStoreDataFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    
    
    NSDictionary* params = @{@"q" : (self.searchStr ? self.searchStr : @""),
                             @"cityId" : cityID,
                             @"storeType" : storeType,
                             @"sortType" : sortType,
                             @"page" : @(self.page)};
    CZJSuccessBlock successBlock = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpAry = [dict valueForKey:@"msg"];
        if (tmpAry.count == 0)
        {
            [weak.storeTableView.footer noticeNoMoreData];
            return;
        }
        if (CZJHomeGetDataFromServerTypeOne == _getdataType) {
            [CZJBaseDataInstance.storeForm setNewStoreListDataWithDictionary:dict];
        }
        else
        {
            [CZJBaseDataInstance.storeForm appendStoreListData:dict];
        }
        
        //返回数据回来还未解析到本地数组中时就不显示下拉刷新
        if (_sortedStoreArys.count == 0)
        {
            weak.storeTableView.footer.hidden = YES;
        }
        else
        {
            weak.storeTableView.footer.hidden = NO;
        }
        [weak.storeTableView.footer endRefreshing];
        
        [self dealWithArray];
        if (_sortedStoreArys.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"无相关门店/(ToT)/~~"];
        }
        else
        {
            [self.storeTableView reloadData];
            weak.storeTableView.footer.hidden = weak.storeTableView.mj_contentH < weak.storeTableView.frame.size.height;
        }
    };

    CZJFailureBlock failBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getStoreDataFromServer];
        }];
    };
    [CZJBaseDataInstance showStoreWithParams:params
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
    if (![[CCLocationManager shareLocation] isLocationEnable]) {
        _refreshLocationBarView.locationNameLabel.text = @"亲，未开启定位功能哦~";
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
    
    [[CCLocationManager shareLocation] getCity:^(NSString *addressString) {
        cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:addressString];
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
            [self performSelector:@selector(moveLocationBarViewOut) withObject:nil afterDelay:1.5];
        }
    }];
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
    }
    if (2 == column)
    {
        storeType = [NSString stringWithFormat:@"%ld", row];
    }
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreDataFromServer];
}


- (void)pullDownMenu:(MXPullDownMenu *)pullDownMenu didSelectCityName:(NSString *)cityName
{
    cityID = [CZJBaseDataInstance.storeForm getCityIDWithCityName:cityName];
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getStoreDataFromServer];
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case CZJButtonTypeMap:
            [self performSegueWithIdentifier:@"segueToNearby" sender:nil];
            break;
            
        default:
            break;
    }
    
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
