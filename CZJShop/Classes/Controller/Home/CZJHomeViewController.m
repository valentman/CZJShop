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
#import "CZJLoginController.h"
#import "CZJDetailViewController.h"
#import "CZJCategoryController.h"
#import "CZJMiaoShaController.h"

@interface CZJHomeViewController ()<
UISearchBarDelegate,
UITableViewDelegate,
UITableViewDataSource,
PullTableViewDelegate,
CZJNaviagtionBarViewDelegate,
CZJImageViewTouchDelegate,
CZJServiceCellDelegate,
CZJGoodsRecommendCellDelegate,
CZJMiaoShaCellDelegate
>
{
    NSString* _serviceTypeId;
    NSString* _touchedStoreItemPid;
    BOOL isLoadSuccess;
}
@property (strong, nonatomic) IBOutlet PullTableView *homeTableView;
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
    [self getHomeDataFromServer:CZJHomeGetDataFromServerTypeOne];
    [self.homeTableView reloadData];
    [CZJUtils setExtraCellLineHidden:self.homeTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [((CZJCarInfoCell*)[self.homeTableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell"]).autoScrollTimer setFireDate:[NSDate distantPast]];
    [self.naviBarView refreshShopBadgeLabel];
    self.naviBarView.hidden = NO;
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.isJumpToAnotherView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [((CZJCarInfoCell*)[self.homeTableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell"]).autoScrollTimer setFireDate:[NSDate distantFuture]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)propertysInit
{
    DLog();
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
    self.navigationController.navigationBarHidden = YES;
    
    //导航栏添加搜索栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeHome];
}


- (void)dealWithInitTableView
{
    DLog();
    self.homeTableView.pullDelegate = self;
    self.homeTableView.delegate = self;
    self.homeTableView.dataSource = self;
    [self.homeTableView setDelegate:self];
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
    [self.tabBarController.tabBar setTintColor:RGB(235, 20, 20)];
    //    NSArray *items = self.tabBarController.tabBar.items;
    //    [[items objectAtIndex:eTabBarItemShop] setBadgeValue:@"1"];
}


- (void)getHomeDataFromServer:(CZJHomeGetDataFromServerType)dataType
{
    if (_errorView) {
        [_errorView removeFromSuperview];
    }
    
    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        isLoadSuccess = YES;
        [self dealWithArray];
        [self.homeTableView reloadData];
        if (self.homeTableView.pullTableIsRefreshing == YES)
        {
            self.homeTableView.pullLastRefreshDate = [NSDate date];
        }
        self.homeTableView.pullTableIsLoadingMore = NO;
        self.homeTableView.pullTableIsRefreshing = NO;
        
        switch (dataType) {
            case CZJHomeGetDataFromServerTypeOne:
                [self loadMoreTable];
                break;
                
            case CZJHomeGetDataFromServerTypeTwo:
                self.page++;
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
    srand((unsigned)time(0));
    if ([CZJUtils isTimeCrossFiveMin:5] && 1 == self.page)
    {
        int randNum = rand()%900000+100000;
        [USER_DEFAULT setObject:@(randNum) forKey:kUserDefaultRandomCode];
    }
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


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //依据不同的内容加载不同类型的Cell
    switch (indexPath.section) {
        case 0:
        {//ad广告展示
            CZJActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJActivityCell" forIndexPath:indexPath];
            if (_activityArray.count > 0 && !cell.isInit)
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
            if (cell && _serviceArray.count > 0 && !cell.isInit)
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
            CZJCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCarInfoCell" forIndexPath:indexPath];
            if (cell && _carInfoArray.count > 0 && !cell.isInit)
            {
                [cell initWithCarInfoDatas:_carInfoArray andButtonClick:^(id data) {
                    CarInfoForm* carInfoForm = (CarInfoForm*)data;
                    [self showWebViewWithURL:carInfoForm.url andTitle:@"汽车资讯"];
                }];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 3:
        {//秒杀数据
            if (1 == indexPath.row) {
                CZJMiaoShaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCell" forIndexPath:indexPath];
                if (cell && _miaoShaArray.count > 0 && !cell.isInit)
                {
                    cell.delegate = self;
                    [cell initMiaoShaInfoWithData:_miaoShaArray];
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (0 == indexPath.row)
            {
                CZJMiaoShaCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaCellHeader" forIndexPath:indexPath];
                [cell.miaoShaChangCi setTitle:@"" forState:UIControlStateNormal];
                if (cell && _miaoShaArray.count > 0 && !cell.isInit)
                {
                    TICK;
                    NSInteger timeinteval = [CZJBaseDataInstance.homeForm.serverTime integerValue] - [((CZJMiaoShaTimesForm*)CZJBaseDataInstance.homeForm.skillTimes[0]).skillTime integerValue];
                    TOCK;
                    [cell initHeaderWithTimestamp:timeinteval];
                }
                
                return cell;
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
            if (0 == indexPath.row)
            {
                CZJLimitBuyCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCellHeader" forIndexPath:indexPath];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJLimitBuyCell *cell = (CZJLimitBuyCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJLimitBuyCell" forIndexPath:indexPath];
                if (cell && _limitBuyArray.count > 0 && !cell.isInit)
                {
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
                if (cell && _brandRecommentArray.count > 0 && !cell.isInit)
                {
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
            if (0 == indexPath.row)
            {
                CZJSpecialRecoCellHeader* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecoCellHeader" forIndexPath:indexPath];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJSpecialRecommendCell *cell = (CZJSpecialRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJSpecialRecommendCell" forIndexPath:indexPath];
                if (cell && _specialRecommentArray.count > 0 && !cell.isInit)
                {
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
                cell.backgroundColor = CZJTableViewBGColor;
                return cell;
            }
            else
            {
                CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
                cell.backgroundColor = CZJTableViewBGColor;
                cell.delegate = self;
                float width = (PJ_SCREEN_WIDTH - 30) / 2;
                cell.imageOneHeight.constant = width;
                cell.imageTwoHeight.constant = width;
                if (cell && _goodsRecommentArray.count > 0)
                {
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
            return 100;
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
            return 250;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (isLoadSuccess)
    {
        if ((_carInfoArray.count == 0 && section == 2)||
            (_miaoShaArray.count == 0 && section == 3)||
            (_limitBuyArray.count == 0 && section == 5)||
            (_brandRecommentArray.count == 0 && section == 6)||
            (_bannerTwoArray.count == 0 && section == 7)||
            (_specialRecommentArray.count == 0 && section == 8)){
            return 10;
        }
    }
    else
    {
        if ((section == 2)||
            (section == 3)||
            (section == 5)||
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
}


#pragma mark- CZJActivityDelegate
- (void)showDetailInfoWithForm:(id)form
{
    ServiceForm* serviceForm = (ServiceForm*)form;
    if ([serviceForm.name isEqualToString:@"更多服务"])
    {
        CZJCategoryController* cateVC = (CZJCategoryController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"CategorySBID"];
        cateVC.hidesBottomBarWhenPushed = YES;
        cateVC.viewFromWhere = @"homeView";
        [self.navigationController pushViewController:cateVC animated:YES];
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
    [self showWebViewWithURL:url andTitle:@"活动详情"];
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
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


#pragma mark- CZJGoodsRecommendCellDelegate
- (void)clickRecommendCellWithID:(NSString*)itemID
{
    _touchedStoreItemPid = itemID;
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
        detailVC.storeItemPid = _touchedStoreItemPid;
        detailVC.detaiViewType = CZJDetailTypeGoods;
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


- (void)showWebViewWithURL:(NSString*)url andTitle:(NSString*)title
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = url;
    [self.navigationController pushViewController:webView animated:YES];
    
}
@end
