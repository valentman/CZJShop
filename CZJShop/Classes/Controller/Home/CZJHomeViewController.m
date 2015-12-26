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
#import "CZJNaviagtionBarView.h"
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
#import "CZJLoginController.h"

@interface CZJHomeViewController ()<
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    PullTableViewDelegate,
    CZJNaviagtionBarViewDelegate,
    CZJImageViewTouchDelegate,
    CZJServiceCellDelegate,
    CZJViewControllerDelegate
>
{
    NSString* _serviceTypeId;
}
@property (strong, nonatomic) IBOutlet PullTableView *homeTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnToTop;
@property (strong, nonatomic) CZJNaviagtionBarView *navibarView;
@property (nonatomic, strong) UIView* statusBarBgView;
@property (nonatomic, strong) UIWindow *window;

- (IBAction)tapToTop:(id)sender;
@end

@implementation CZJHomeViewController


#pragma mark- InitSection

- (void)viewDidLoad {
    DLog();
    [super viewDidLoad];
    
    [self propertysInit];
    [self dealWithInitNavigationBar];
    [self dealWithInitTableView];
    [self dealWithInitTabbar];
    [self getHomeDataFromServer:CZJHomeGetDataFromServerTypeOne];
    [self.homeTableView reloadData];
    [CZJUtils setExtraCellLineHidden:self.homeTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [((CZJCarInfoCell*)[self.homeTableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell"]).autoScrollTimer setFireDate:[NSDate distantPast]];
    self.navigationController.navigationBarHidden = NO;

}

- (void)viewDidAppear:(BOOL)animated
{
    [self.homeTableView setContentOffset:CGPointMake(0,0) animated:NO];
    self.isJumpToAnotherView = YES;
    [UIView animateWithDuration:0.5 animations:^{
        _navibarView.hidden = NO;
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [((CZJCarInfoCell*)[self.homeTableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell"]).autoScrollTimer setFireDate:[NSDate distantFuture]];
}

- (void)propertysInit
{
    //隐藏toTop按钮
    self.btnToTop.hidden = YES;
    self.isFirst = YES;
    self.isJumpToAnotherView = NO;
    self.page = 1;
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
    
    
    //导航栏添加搜索栏
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    _navibarView = [[CZJNaviagtionBarView alloc]initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeHome];
    _navibarView.delegate = self;
    [self.navigationController.navigationBar addSubview:_navibarView];
    CGRect statusviewbound = CGRectMake(0, -20, mainViewBounds.size.width, 20);
    _statusBarBgView = [[UIView alloc]initWithFrame:statusviewbound];
    [self.navigationController.navigationBar addSubview:_statusBarBgView];
}


- (void)dealWithInitTableView
{
    DLog();
    self.homeTableView.pullDelegate = self;
    self.homeTableView.delegate = self;
    self.homeTableView.dataSource = self;
    [self.homeTableView setDelegate:self];
    [self.homeTableView setBackgroundColor:RGB(239, 239, 239)];
    self.homeTableView.showsVerticalScrollIndicator = NO;
    self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.homeTableView.rowHeight = UITableViewAutomaticDimension;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
}

- (void)dealWithInitTabbar
{
    //TabBarItem选中颜色设置及右上角标记设置
    [self.tabBarController.tabBar setTintColor:RGB(240, 16, 34)];
    NSArray *items = self.tabBarController.tabBar.items;
//    [[items objectAtIndex:eTabBarItemShop] setBadgeValue:@"1"];
}


- (void)getHomeDataFromServer:(CZJHomeGetDataFromServerType)dataType
{
    if (_errorView) {
        [_errorView removeFromSuperview];
    }

    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        
        [self dealWithArray];
        switch (dataType) {
            case CZJHomeGetDataFromServerTypeOne:
            {
                DLog(@"Get Home Data From Server Success...");
                _isFirst = YES;
                [self.homeTableView reloadData];
                
                if (self.homeTableView.pullTableIsRefreshing == YES)
                {
                    self.homeTableView.pullLastRefreshDate = [NSDate date];
                }
                self.homeTableView.pullTableIsLoadingMore = NO;
                self.homeTableView.pullTableIsRefreshing = NO;
            }
                break;
                
            case CZJHomeGetDataFromServerTypeTwo:
            {
                DLog(@"Get Goods Data From Server Success...");
                [self.homeTableView reloadData];
                if (self.homeTableView.pullTableIsRefreshing == YES)
                {
                    self.homeTableView.pullLastRefreshDate = [NSDate date];
                }
                self.homeTableView.pullTableIsLoadingMore = NO;
                self.homeTableView.pullTableIsRefreshing = NO;
                
            }
                break;
                
            default:
                break;
        }
    };
    
    CZJFailureBlock failBlock = ^{};
    
    [CZJBaseDataInstance  showHomeType:dataType
                                  page:self.page
                               Success:successBlock
                                  fail:failBlock];
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


#pragma mark- PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.1];
}

- (void)refreshTable
{
    self.page = 1;
    [self getHomeDataFromServer:CZJHomeGetDataFromServerTypeOne];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    [self performSelector:@selector(loadMoreTable) withObject:nil afterDelay:0.1];
}

- (void)loadMoreTable
{
    self.page++;
    [self getHomeDataFromServer:CZJHomeGetDataFromServerTypeTwo];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isJumpToAnotherView) {
        return;
    }
    float contentOffsetY = [scrollView contentOffset].y;
    if (contentOffsetY < 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [_navibarView setAlpha:0.0];
            [_statusBarBgView setAlpha:0.0];
        }];
        [_navibarView setBackgroundColor:RGBA(235, 35, 38, 0)];
        [_statusBarBgView setBackgroundColor:RGBA(235, 35, 38, 0)];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            [_navibarView setAlpha:1.0];
            [_statusBarBgView setAlpha:1.0];
        }];

        float alphaValue = contentOffsetY * 0.5 / 200;
        if (alphaValue > 0.7)
        {
            alphaValue = 0.7;
        }
        [_navibarView setBackgroundColor:RGBA(235, 20, 20, alphaValue)];
        [_statusBarBgView setBackgroundColor:RGBA(235, 20, 20, alphaValue)];
    }
    if (contentOffsetY > 600) {
        self.btnToTop.hidden = NO;
    }
    else
    {
        self.btnToTop.hidden = YES;
    }
    
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //依据不同的内容加载不同类型的Cell
    switch (indexPath.section) {
        case 0:
        {//ad广告展示
            CZJActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJActivityCell" forIndexPath:indexPath];
            if (_activityArray.count > 0) {
                [cell someMethodNeedUse:indexPath DataModel:_activityArray];
                cell.delegate = self;
            }
            return cell;
        }
            break;
            
        case 1:
        {//服务列表
            CZJServiceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJServiceCell" forIndexPath:indexPath];
            if (cell && _serviceArray.count > 0 && !cell.isInit) {
                [cell initServiceCellWithDatas:_serviceArray];
                cell.delegate = self;
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 2:
        {//汽车资讯
            CZJCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell" forIndexPath:indexPath];
            if (cell && _carInfoArray.count > 0 && !cell.isInit)
            {
                [cell initWithCarInfoDatas:_carInfoArray];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 3:
        {//秒杀数据
            if (1 == indexPath.row) {
                CZJMiaoShaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCell" forIndexPath:indexPath];
                if (cell && _miaoShaArray.count > 0 && !cell.isInit) {
                    [cell initMiaoShaInfoWithData:_miaoShaArray];
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (0 == indexPath.row)
            {
                CZJMiaoShaCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCellHeader" forIndexPath:indexPath];
                [headerView initHeaderWithTimestamp:CZJBaseDataInstance.homeForm.serverTime];
                return headerView;
            }
        }
            break;
        case 4:
        {//广告栏一
            CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
            [cell initBannerOneWithDatas:_bannerOneArray];
            return cell;
        }
            break;
        case 5:
        {//限量购买
            if (0 == indexPath.row) {
                CZJLimitBuyCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCellHeader" forIndexPath:indexPath];
                return headerView;
            }
            else if (1 == indexPath.row)
            {
                CZJLimitBuyCell *cell = (CZJLimitBuyCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCell" forIndexPath:indexPath];
                [cell initLimitBuyWithDatas:_limitBuyArray];
                return cell;
            }
            
        }
            break;
        case 6:
        {//品牌推荐
            if (0 == indexPath.row) {
                CZJBrandRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJBrandRecoCellHeader" forIndexPath:indexPath];
                return headerView;
            }
            if (1 == indexPath.row) {
                CZJBrandRecommendCell *cell = (CZJBrandRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJBrandRecommendCell" forIndexPath:indexPath];
                if (cell && _brandRecommentArray.count > 0 && !cell.isInit) {
                    [cell initBrandRecommendWithDatas:_brandRecommentArray];
                }
                return cell;
            }
        }
            break;
        case 7:
        {//广告条二
            CZJAdBanerPlusCell *cell = (CZJAdBanerPlusCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerPlusCell" forIndexPath:indexPath];
            [cell initBannerTwoWithDatas:_bannerTwoArray];
            return cell;
        }
            break;
        case 8:
        {//特别推荐
            if (0 == indexPath.row) {
                CZJSpecialRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecoCellHeader" forIndexPath:indexPath];
                return headerView;
            }
            else if (1 == indexPath.row) {
                CZJSpecialRecommendCell *cell = (CZJSpecialRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecommendCell" forIndexPath:indexPath];
                if (cell && _specialRecommentArray.count > 0 && !cell.isInit) {
                    [cell initSpecialRecommendWithDatas:_specialRecommentArray];
                }
                
                return cell;
            }
        }
            break;
            
        case 9:
        {
            if (0 == indexPath.row) {
                CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
                headerView.backgroundColor = [UIColor clearColor];
                headerView.backgroundView.backgroundColor = [UIColor clearColor];
                return headerView;
            }
            else
            {
                CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
                DLog(@"%@",cell);
                if (cell && _goodsRecommentArray.count > 0) {
                    [cell initGoodsRecommendWithDatas:_goodsRecommentArray[indexPath.row - 1]];
                }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //广告条和汽车头条可能没有信息数据，则返回0
    if ((_bannerOneArray.count == 0 && section == 4)||
        (_bannerTwoArray.count == 0 && section == 7)||
        (_carInfoArray.count == 0 && section == 2) ||
        (_specialRecommentArray.count == 0 && section == 8) ||
        (_brandRecommentArray.count == 0 && section == 6) ||
        (_limitBuyArray.count == 0 && section == 5)||
        (_miaoShaArray.count == 0 && section == 3))
    {
        return 0;
    }
    if (9 == section)
    {
       return _goodsRecommentArray.count + 1;
    }
    if (3 == section ||
        5 == section ||
        6 == section ||
        8 == section) {
        return 2;
    }
    return 1;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            
        }
            break;
        case 1:{
            
        }
            break;
        case 2:{
            
        }
            break;
        case 3:{
            _htmlType = eRecommandHtml;
            GoodsRecommendForm* rFrom = [_brandRecommentArray objectAtIndex:indexPath.row];
            _webViewTitle = @"服务详情";
//            [self performSegueWithIdentifier:@"showWebViewID" sender:self];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 200;
            break;
        case 1:
            return 180;
            break;
        case 2:
            return 39;
            break;
        case 3:
            if (0 == indexPath.row) {
                return 35;
            }
            if (1 == indexPath.row) {
                return 135;
            }
           
            break;
        case 4:
            return 50;
            break;
        case 5:
            if (0 == indexPath.row) {
                return 35;
            }
            if (1 == indexPath.row) {
                return 135;
            }
            break;
        case 6:
            if (0 == indexPath.row) {
                return 35;
            }
            if (1 == indexPath.row) {
                return 153;
            }
            break;
            
        case 7:
            return 50;
            break;
        case 8:
            if (0 == indexPath.row) {
                return 35;
            }
            if (1 == indexPath.row) {
                return 200;
            }
            break;
        case 9:
            if (0 == indexPath.row) {
                return 35;
            }
            if (1 <= indexPath.row) {
                return 245;
            }
            break;
        default:
            return 200;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (2 == section ||
        3 == section ||
        5 == section ||
        6 == section){
        return 7;
    }

    return 0;
}


#pragma mark- CZJActivityDelegate
- (void)showDetailInfoWithForm:(id)form
{
    _serviceTypeId = ((ServiceForm*)form).typeId;
    [USER_DEFAULT setValue:_serviceTypeId forKey:kUserDefaultServiceTypeID];
    [self performSegueWithIdentifier:@"pushToServiceDetail" sender:self];
}

-(void)showActivityHtmlWithUrl:(NSString*)url
{
    return;
    _curUrl = url;
    _htmlType =  eActivityHtml;
    _webViewTitle = @"活动详情";
    [self performSegueWithIdentifier:@"pushToServiceDetail" sender:self];
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
        {
//            [CZJUtils showLoginView:self];
            [CZJUtils showShoppingCartView:self];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark- CZJViewControllerDelegate
- (void)didCancel:(id)controller
{
    if ([controller isKindOfClass: [CZJLoginController class]] )
    {
        [CZJUtils removeLoginViewFromCurrent:self];
    }
    else if ([controller isKindOfClass: [CZJShoppingCartController class]])
    {
        [CZJUtils removeShoppintCartViewFromCurrent:self];
    }
    
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
}

#pragma mark- IBAction
- (IBAction)tapToTop:(id)sender
{
    [self.homeTableView setContentOffset:CGPointMake(0,0) animated:YES];
}



@end
