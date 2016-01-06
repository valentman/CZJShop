//
//  CZJGoodsListController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsListController.h"
#import "CZJNaviagtionBarView.h"
#import "MXPullDownMenu.h"
#import "UIImageView+WebCache.h"
#import "PullTableView.h"
#import "CZJGoodsRecoCollectionCell.h"
#import "CZJGoodsListCell.h"
#import "CZJBaseDataManager.h"
#import "CZJGoodsForm.h"
#import "CZJGoodsListFilterController.h"
#import "CZJDetailViewController.h"


@interface CZJGoodsListController ()
<
PullTableViewDelegate,
MXPullDownMenuDelegate,
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource,
UICollectionViewDelegate,
CZJNaviagtionBarViewDelegate
>
{
    CZJHomeGetDataFromServerType _getdataType;
    NSMutableDictionary* goodsListPostParams;
    NSMutableArray* goodsListAry;
    BOOL isArrangeByList;
    NSString* _choosedStoreitemPid;
}

@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *topNaviBarView;
@property (weak, nonatomic) IBOutlet MXPullDownMenu *pullDownMenuView;
@property (weak, nonatomic) IBOutlet PullTableView *myGoodsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *myGoodsCollectionView;

@property (assign, nonatomic)NSInteger page;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIView *upView;

@end

@implementation CZJGoodsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    
    [self getGoodsListDataFromServer];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_topNaviBarView refreshShopBadgeLabel];
}


- (void)initDatas
{
    goodsListAry = [NSMutableArray array];
    goodsListPostParams = [NSMutableDictionary dictionary];
    self.page = 1;
    isArrangeByList = YES;
    
    //post参数初始化
    [goodsListPostParams setObject:@"0" forKey:@"cityId"];
    [goodsListPostParams setObject:@"0" forKey:@"storeType"];
    [goodsListPostParams setObject:@"" forKey:@"modelId"];
    [goodsListPostParams setObject:self.typeId forKey:@"typeId"];
    [goodsListPostParams setObject:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
    
}


- (void)initViews
{
    //导航栏添加搜索栏
    self.navigationController.navigationBarHidden = YES;
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    [self.topNaviBarView initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeGoodsList].delegate = self;
    [self.topNaviBarView setBackgroundColor:UIColorFromRGB(0xF3F4F6)];
    
    //下拉菜单筛选条件初始
    NSArray* sortTypes = @[@"综合排序", @"销量", @"人气", @"评论",@"附近"];
    NSArray* storeTypes = @[@"价格"];
    NSArray* filterTypes = @[@"筛选"];
    NSArray* menuArray = @[sortTypes,storeTypes,filterTypes];
    [self.pullDownMenuView initWithArray:menuArray AndType:CZJMXPullDownMenuTypeGoods WithFrame:self.pullDownMenuView.frame].delegate = self;
    
    //TableView
    self.myGoodsTableView.delegate = self;
    self.myGoodsTableView.dataSource = self;
    UINib* nib1 = [UINib nibWithNibName:@"CZJGoodsListCell" bundle:nil];
    [self.myGoodsTableView registerNib:nib1 forCellReuseIdentifier:@"CZJGoodsListCell"];
    
    //CollectionView
    self.myGoodsCollectionView.delegate = self;
    self.myGoodsCollectionView.dataSource = self;
//    self.myGoodsCollectionView.backgroundColor = [UIColor whiteColor];
    UINib *nib=[UINib nibWithNibName:kCZJCollectionCellReuseIdGoodReco bundle:nil];
    [self.myGoodsCollectionView registerNib: nib forCellWithReuseIdentifier:kCZJCollectionCellReuseIdGoodReco];
}

- (void)getGoodsListDataFromServer
{
    DLog(@"storeparameters:%@", [goodsListPostParams description]);
    CZJSuccessBlock successBlock = ^(id json) {
        [self dealWithArray];
        if (isArrangeByList) {
            [self.myGoodsCollectionView setHidden:YES];
            [self.myGoodsTableView setHidden:NO];
            [self.myGoodsTableView reloadData];
        }
        else
        {
            [self.myGoodsTableView setHidden:YES];
            [self.myGoodsCollectionView setHidden:NO];
            [self.myGoodsCollectionView reloadData];
        }
        
        if (self.myGoodsTableView.pullTableIsRefreshing == YES)
        {
            self.myGoodsTableView.pullLastRefreshDate = [NSDate date];
        }
        self.myGoodsTableView.pullTableIsLoadingMore = NO;
        self.myGoodsTableView.pullTableIsRefreshing = NO;
    };
    
    [CZJBaseDataInstance loadGoodsList:goodsListPostParams
                                  type:_getdataType
                               success:successBlock
                                  fail:^{}];
}


- (void)dealWithArray
{
    [goodsListAry removeAllObjects];
    goodsListAry = [[CZJBaseDataInstance goodsForm] goodsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
    _getdataType = CZJHomeGetDataFromServerTypeOne;
    [self getGoodsListDataFromServer];
    self.page = 1;
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    _getdataType = CZJHomeGetDataFromServerTypeTwo;
    self.page++;
    [self getGoodsListDataFromServer];;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
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
    [cell.goodImageView sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:nil];
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
    cell.iconImageView.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:nil];
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
    
    CZJGoodsListFilterController *goodsListFilterController = [[CZJGoodsListFilterController alloc] init];
    goodsListFilterController.delegate = self;
    goodsListFilterController.typeId = self.typeId;
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
        [self.myGoodsTableView setHidden:YES];
        [self.myGoodsCollectionView setHidden:NO];
        [self.myGoodsCollectionView reloadData];
        [self.topNaviBarView.btnArrange setBackgroundImage:[UIImage imageNamed:@"pro_btn_list"] forState:UIControlStateNormal];
    }
    else
    {
        isArrangeByList = YES;
        [self.myGoodsCollectionView setHidden:YES];
        [self.myGoodsTableView setHidden:NO];
        [self.myGoodsTableView reloadData];
        [self.topNaviBarView.btnArrange setBackgroundImage:[UIImage imageNamed:@"pro_btn_large"] forState:UIControlStateNormal];
    }
}

#pragma mark -CZJServiceFilterDelegate
- (void)chooseFilterOK
{
    //更新参数，重新请求数据刷新

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
    }
}


@end
