//
//  CZJGoodsListController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsListController.h"
#import "MXPullDownMenu.h"
#import "PullTableView.h"
#import "CZJGoodsRecoCollectionCell.h"
#import "CZJGoodsListCell.h"
#import "CZJBaseDataManager.h"
#import "CZJGoodsListFilterController.h"
#import "CZJDetailViewController.h"


@interface CZJGoodsListController ()
<
MXPullDownMenuDelegate,
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource,
UICollectionViewDelegate,
CZJNaviagtionBarViewDelegate,
CZJFilterControllerDelegate
>
{
    __block CZJHomeGetDataFromServerType _getdataType;
    NSMutableArray* goodsListAry;
    NSArray* currentChooseFilterArys;
    BOOL isArrangeByList;
    NSString* _choosedStoreitemPid;
    
//    NSString* citID;
    NSString* sortType;
    NSString* modelID;
    NSString* brandID;
    NSString* stockFlag;
    NSString* promotionFlag;
    NSString* recommendFlag;
    NSString* startPrice;
    NSString* endPrice;
    NSString* attrJson;
    
    BOOL _isTouch;
    float lastContentOffsetY;
    
    MJRefreshAutoNormalFooter* tableRefreshFooter;
    MJRefreshAutoNormalFooter* collectionRefreshFooter;
    
    CGPoint pullDownMenuOriginPoint;        //下拉列表区原始位置
    CGPoint naviBraviewOriginPoint;         //导航栏原始位置
}

@property (strong, nonatomic) MXPullDownMenu *pullDownMenuView;
@property (strong, nonatomic) UITableView* myTableView;
@property (strong, nonatomic) UICollectionView *myGoodsCollectionView;

@property (assign, nonatomic)NSInteger page;

@end

@implementation CZJGoodsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getGoodsListDataFromServer];
}

- (void)initDatas
{
    goodsListAry = [NSMutableArray array];
    currentChooseFilterArys = [NSArray array];
    isArrangeByList = YES;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    
    //post参数初始化
    self.page = 1;
    sortType = @"0";
    modelID = @"";
    brandID = @"";
    stockFlag = @"0";
    recommendFlag = @"0";
    promotionFlag = @"0";
    attrJson = @"";
    startPrice = @"";
    endPrice = @"";
}

- (void)initViews
{
    //导航栏添加搜索栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeGoodsList];
    self.naviBarView.detailType = CZJDetailTypeGoods;
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"综合排序", @"销量", @"新品", @"评论",@"附近"];
    NSArray* storeTypes = @[@"价格"];
    NSArray* filterTypes = @[@"筛选"];
    NSArray* menuArray = @[sortTypes,storeTypes,filterTypes];
    _pullDownMenuView  = [[MXPullDownMenu alloc]initWithArray:menuArray AndType:CZJMXPullDownMenuTypeGoods WithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46)];
    _pullDownMenuView.delegate = self;
    _pullDownMenuView.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
    [self.view addSubview:_pullDownMenuView];
    
    //TableView
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = YES;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.myTableView];
    
    UINib* nib1 = [UINib nibWithNibName:@"CZJGoodsListCell" bundle:nil];
    [self.myTableView registerNib:nib1 forCellReuseIdentifier:@"CZJGoodsListCell"];
    
    
    //CollectionView
    UICollectionViewFlowLayout* goodCollectioinLayout = [[UICollectionViewFlowLayout alloc]init];
    [goodCollectioinLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.myGoodsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110) collectionViewLayout:goodCollectioinLayout];
    self.myGoodsCollectionView.delegate = self;
    self.myGoodsCollectionView.dataSource = self;
    self.myGoodsCollectionView.backgroundColor = [UIColor clearColor];
    UINib *nib=[UINib nibWithNibName:kCZJCollectionCellReuseIdGoodReco bundle:nil];
    [self.myGoodsCollectionView registerNib: nib forCellWithReuseIdentifier:kCZJCollectionCellReuseIdGoodReco];
    [self.view addSubview:self.myGoodsCollectionView];
}

- (void)getGoodsListDataFromServer
{
    DLog(@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",sortType,self.typeId,self.searchStr,modelID,brandID,stockFlag,promotionFlag,recommendFlag,attrJson,startPrice,endPrice,@(self.page));
    NSDictionary* goodsListPostParams = @{@"itemType" : @"1",
                                          @"sortType" : sortType,
                                          @"typeId" : self.typeId,
                                          @"q" : (self.searchStr ? self.searchStr : @""),
                                          @"modelId" : modelID,
                                          @"brandId" : brandID,
                                          @"stockFlag" : stockFlag,
                                          @"promotionFlag" : promotionFlag,
                                          @"recommendFlag" : recommendFlag,
                                          @"attrJson" : attrJson,
                                          @"startPrice" : startPrice,
                                          @"endPrice" : endPrice,
                                          @"page" : @(self.page)};
    DLog(@"storeparameters:%@", [goodsListPostParams description]);
    __weak typeof(self) weak = self;
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    CZJSuccessBlock successBlock = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:weak.view animated:YES];
        //返回数据回来还未解析到本地数组中时就添加下拉刷新footer
        if (goodsListAry.count == 0)
        {
            tableRefreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
                _getdataType = CZJHomeGetDataFromServerTypeTwo;
                weak.page++;
                [weak getGoodsListDataFromServer];;
            }];
            collectionRefreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
                _getdataType = CZJHomeGetDataFromServerTypeTwo;
                weak.page++;
                [weak getGoodsListDataFromServer];;
            }];
            weak.myTableView.footer = tableRefreshFooter;
            weak.myGoodsCollectionView.footer = collectionRefreshFooter;
            weak.myTableView.footer.hidden = YES;
            weak.myGoodsCollectionView.footer.hidden = YES;
        }
        if (isArrangeByList) {
            [weak.myTableView.footer endRefreshing];
        }
        else
        {
            [weak.myGoodsCollectionView.footer endRefreshing];
        }
        
        
        //解析返回的数据
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {//如果是下拉刷新类型添加返回数据到当前数组中
            NSArray* tmpAry = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
            if (tmpAry.count > 0)
            {
                [goodsListAry addObjectsFromArray:tmpAry];
                if (tmpAry.count < 20)
                {
                    [tableRefreshFooter noticeNoMoreData];
                    [collectionRefreshFooter noticeNoMoreData];
                }
                if (isArrangeByList) {
                    [weak.myGoodsCollectionView setHidden:YES];
                    [weak.myTableView setHidden:NO];
                    [weak.myTableView reloadData];
                }
                else
                {
                    [weak.myTableView setHidden:YES];
                    [weak.myGoodsCollectionView setHidden:NO];
                    [weak.myGoodsCollectionView reloadData];
                }
            }
            else
            {
                [tableRefreshFooter noticeNoMoreData];
                [collectionRefreshFooter noticeNoMoreData];
            }
        }
        else
        {
            //如果是第一次进入数据请求
            goodsListAry = [[CZJStoreServiceForm objectArrayWithKeyValuesArray:dict] mutableCopy];
            if (goodsListAry.count == 0)
            {
                [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有该品类商品/(ToT)/~~"];
            }
            else
            {
                if (isArrangeByList) {
                    [weak.myGoodsCollectionView setHidden:YES];
                    [weak.myTableView setHidden:NO];
                    [weak.myTableView reloadData];
                    weak.myTableView.footer.hidden = weak.myTableView.mj_contentH < weak.myTableView.frame.size.height;
                }
                else
                {
                    [weak.myTableView setHidden:YES];
                    [weak.myGoodsCollectionView setHidden:NO];
                    [weak.myGoodsCollectionView reloadData];
                    weak.myGoodsCollectionView.footer.hidden = weak.myGoodsCollectionView.mj_contentH < weak.myGoodsCollectionView.frame.size.height;;
                }
                
            }
        }
        
    };
    
    [CZJBaseDataInstance loadGoodsList:goodsListPostParams
                                  type:_getdataType
                               success:successBlock
                                  fail:^{
                                      [MBProgressHUD hideAllHUDsForView:weak.view animated:YES];
                                      [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
                                          [weak getGoodsListDataFromServer];
                                      }];
                                  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.naviBarView refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    //获取导航栏和下拉栏原始位置，为了上拉或下拉时动画
    pullDownMenuOriginPoint = _pullDownMenuView.frame.origin;
    naviBraviewOriginPoint = self.naviBarView.frame.origin;
    [[UIApplication sharedApplication]setStatusBarHidden:(self.naviBarView.frame.origin.y < 0)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedBrandID];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPrice];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultEndPrice];
    [USER_DEFAULT setValue:@"" forKey:kUSerDefaultStockFlag];
    [USER_DEFAULT setValue:@"" forKey:kUSerDefaultPromotionFlag];
    [USER_DEFAULT setValue:@"" forKey:kUSerDefaultRecommendFlag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
                _pullDownMenuView.frame = CGRectMake(0, 64, PJ_SCREEN_WIDTH, 46);
                self.myTableView.frame = CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110);
                self.myGoodsCollectionView.frame = CGRectMake(0, 110, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 110);
            } completion:nil];
        }
        else if (!isDraggingDown &&
                 _pullDownMenuView.frame.origin.y > 0 &&
                 _isTouch)
        {
            if ((isArrangeByList && self.myTableView.mj_contentH < self.myTableView.frame.size.height) ||
                (!isArrangeByList && self.myGoodsCollectionView.mj_contentH < self.myGoodsCollectionView.frame.size.height))
            {
                return;
            }
            
            _isTouch = NO;
            DLog(@"上拉");
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.naviBarView.frame = CGRectMake(0, -110, PJ_SCREEN_WIDTH, 44);
                _pullDownMenuView.frame = CGRectMake(0, -46, PJ_SCREEN_WIDTH, 46);
                self.myTableView.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
                self.myGoodsCollectionView.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
            } completion:nil];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isTouch = YES;
    DLog();
}


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJGoodsListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsListCell" forIndexPath:indexPath];
    CZJStoreServiceForm* goodsForm = (CZJStoreServiceForm*)goodsListAry[indexPath.row];
    cell.goodsName.text = goodsForm.itemName;
    NSString* rmb = @"￥";
    cell.goodPrice.text = [rmb stringByAppendingString:goodsForm.currentPrice];
    cell.goodRate.text = goodsForm.goodEvalRate;
    cell.puchaseCount.text = goodsForm.purchaseCount;
    cell.purchaseCountWidth.constant = [CZJUtils calculateTitleSizeWithString:goodsForm.purchaseCount AndFontSize:13].width;
    [cell.goodImageView sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    
    cell.imageOne.hidden = YES;
    cell.imageTwo.hidden = YES;
    if (goodsForm.newlyFlag && !goodsForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_new")];
    }
    else if (!goodsForm.newlyFlag && goodsForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_cu")];
    }
    else if (goodsForm.newlyFlag && goodsForm.promotionFlag)
    {
        cell.imageOne.hidden = NO;
        cell.imageTwo.hidden = NO;
        [cell.imageOne setImage:IMAGENAMED(@"label_icon_new")];
        [cell.imageTwo setImage:IMAGENAMED(@"label_icon_cu")];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (goodsListAry.count > 0)
    {
        return 1;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cout = goodsListAry.count;
    return cout;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 126;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self segueToDetailView:indexPath.row];
}


#pragma mark- imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionVie{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (goodsListAry.count==0) {
        return 0;
    }
    return goodsListAry.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self segueToDetailView:indexPath.item];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CZJGoodsRecoCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCZJCollectionCellReuseIdGoodReco forIndexPath:indexPath];
    DLog(@"%@",cell);
    CZJStoreServiceForm * form;
    form = goodsListAry[indexPath.row];
    
    NSString* rmb = @"￥";
    cell.productName.text = form.itemName;
    cell.productPrice.text = [rmb stringByAppendingString:form.currentPrice];
    cell.iconImageView.backgroundColor= CZJNAVIBARBGCOLOR;
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((PJ_SCREEN_WIDTH - 40)/2, 244);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}


#pragma mark- MXPullDownMenuDelegate
- (void)PullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row
{
    DLog(@"column:%ld, row:%ld",column, row);
    if (0 == column)
    {
        sortType = [NSString stringWithFormat:@"%ld",row];
    }
    [self getGoodsListDataFromServer];
}


- (void)pullDownMenuDidSelectFiliterButton:(MXPullDownMenu*)pullDownMenu
{
    [self actionBtn];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)pullDownMenuDidSelectPriceButton:(MXPullDownMenu*)pullDownMenu
{
    if ([sortType floatValue] < 5)
    {
        sortType = @"5";
    }
    else if ([sortType isEqualToString:@"5"])
    {
        [pullDownMenu animateIndicator:YES];
        sortType = @"6";
    }
    else if ([sortType isEqualToString:@"6"]) {
        [pullDownMenu animateIndicator:NO];
        sortType = @"5";
    }
    [self getGoodsListDataFromServer];
}

- (void)actionBtn{
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    [window makeKeyAndVisible];
    
    CZJGoodsListFilterController *goodsListFilterController = [[CZJGoodsListFilterController alloc] init];
    goodsListFilterController.delegate = self;
    goodsListFilterController.typeId = self.typeId;
    goodsListFilterController.selectedConditionArys = currentChooseFilterArys;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:goodsListFilterController];
    goodsListFilterController.view.frame = window.bounds;
    window.rootViewController = nav;
    self.window = window;

    
    UIView *backView = [[UIView alloc] initWithFrame:self.view.bounds];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [backView addGestureRecognizer:tap];
    [self.view addSubview:backView];
    self.upView = backView;
    self.upView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.window.frame = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.upView.alpha = 1.0;
    } completion:nil];
    
    __weak typeof(self) weak = self;
    [goodsListFilterController setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 animations:^{
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


- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case CZJButtonTypeNaviArrange:
            [self setArrangeMentType];
            
            break;
        case CZJButtonTypeSearchBar:
            
            break;
            
        default:
            break;
    }
}


- (void)setArrangeMentType
{
    if (isArrangeByList)
    {
        isArrangeByList = NO;
        [self.myTableView setHidden:YES];
        [self.myGoodsCollectionView setHidden:NO];
        [self.myGoodsCollectionView reloadData];
        [self.naviBarView.btnArrange setBackgroundImage:[UIImage imageNamed:@"pro_btn_list"] forState:UIControlStateNormal];
    }
    else
    {
        isArrangeByList = YES;
        [self.myGoodsCollectionView setHidden:YES];
        [self.myTableView setHidden:NO];
        [self.myTableView reloadData];
        [self.naviBarView.btnArrange setBackgroundImage:[UIImage imageNamed:@"pro_btn_large"] forState:UIControlStateNormal];
    }
}

#pragma mark -CZJServiceFilterDelegate
- (void)chooseGoodFilterOk:(NSArray *)selectAry andData:(id)data
{
    currentChooseFilterArys = selectAry;
    //更新参数，重新请求数据刷新
    modelID = [USER_DEFAULT valueForKey:kUserDefaultChoosedCarModelID] ?[USER_DEFAULT valueForKey:kUserDefaultChoosedCarModelID] : @"";
    brandID = [USER_DEFAULT valueForKey:kUserDefaultChoosedBrandID] ? [USER_DEFAULT valueForKey:kUserDefaultChoosedBrandID] : @"";
    stockFlag = [USER_DEFAULT valueForKey:kUSerDefaultStockFlag] ? [USER_DEFAULT valueForKey:kUSerDefaultStockFlag] : @"";
    promotionFlag = [USER_DEFAULT valueForKey:kUSerDefaultPromotionFlag] ? [USER_DEFAULT valueForKey:kUSerDefaultPromotionFlag] : @"";
    recommendFlag = [USER_DEFAULT valueForKey:kUSerDefaultRecommendFlag] ? [USER_DEFAULT valueForKey:kUSerDefaultPromotionFlag] : @"";
    attrJson = data ? data :@"";
    DLog(@"%@",attrJson.keyValues);
    startPrice = [USER_DEFAULT valueForKey:kUserDefaultStartPrice];
    endPrice = [USER_DEFAULT valueForKey:kUserDefaultEndPrice];
    [self getGoodsListDataFromServer];
}


#pragma mark - Navigation
- (void)segueToDetailView:(NSInteger)row
{
    CZJStoreServiceForm* serviceForm = (CZJStoreServiceForm*)goodsListAry[row];
    _choosedStoreitemPid = serviceForm.storeItemPid;
    [self performSegueWithIdentifier:@"segueToGoodsDetail" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToGoodsDetail"])
    {
        CZJDetailViewController* serviceDetailCon = segue.destinationViewController;
        serviceDetailCon.storeItemPid = _choosedStoreitemPid;
        serviceDetailCon.detaiViewType = CZJDetailTypeGoods;
        serviceDetailCon.promotionType = CZJGoodsPromotionTypeGeneral;
        serviceDetailCon.promotionPrice = @"";
    }
}
@end
