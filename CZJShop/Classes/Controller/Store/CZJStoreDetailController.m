//
//  CZJStoreDetailController.m
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import "CZJStoreDetailController.h"
#import "CZJNaviagtionBarView.h"
#import "CZJStoreDetailHeadCell.h"
#import "CZJStoreDescribeTwoCell.h"
#import "CZJStoreDescribeCell.h"
#import "CZJBaseDataManager.h"
#import "UIImageView+WebCache.h"
#import "CZJShoppingCartForm.h"
#import "CZJStoreDetailForm.h"

@interface CZJStoreDetailController ()
<
CZJNaviagtionBarViewDelegate,
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* _activityArray;     //活动数据
    NSMutableArray* _imgsArray;         //服务列表
    NSMutableArray* _recommendArray;    //推荐列表
    NSMutableArray* _couponsArray;      //优惠券数据
    NSMutableArray* _bannerOneArray;    //广告条
    NSMutableArray* _goodsTypesArray;   //商品类型
    NSMutableArray* _serviceTypesArray; //服务类型
    NSMutableArray* _serviceAndGoodsArray; //服务和商品
    
    CZJStoreDetailForm* _storeDetailForm;
    float lastContentOffsetY;
}
@property (strong, nonatomic) IBOutlet CZJNaviagtionBarView *naviBarView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UIView* topView;

@end

@implementation CZJStoreDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getStoreDetailDataFromServer];
}

- (void)initDatas
{
    lastContentOffsetY = 0;
    _activityArray = [NSMutableArray array];
    _imgsArray = [NSMutableArray array];
    _recommendArray = [NSMutableArray array];
    _couponsArray = [NSMutableArray array];
    _bannerOneArray = [NSMutableArray array];
    _goodsTypesArray = [NSMutableArray array];
    _serviceTypesArray = [NSMutableArray array];
    _serviceAndGoodsArray = [NSMutableArray array];
}

- (void)initViews
{
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.naviBarView initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeStoreDetail].delegate = self;
    [self.naviBarView.customSearchBar setHidden:YES];
    [self.buttomView setBackgroundColor:RGBA(255, 255, 255, 0.9)];
    
    NSArray* nibArys = @[@"CZJStoreDetailHeadCell",
                         @"CZJStoreDescribeCell",
                         @"CZJStoreDescribeTwoCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topView.hidden = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    UIView* view = VIEWWITHTAG(self.myTableView, 500);
    CGRect frame = view.frame;
    DLog(@"offset:%f",frame.origin.y);
    [self.myTableView setContentOffset:CGPointMake(0, frame.origin.y - 64)];
}

- (void)getStoreDetailDataFromServer
{
    NSDictionary* params = @{@"bigTypeId" : @"0",
                             @"typeId" : @"0",
                             @"q" : @"",
                             @"sortType" : @"",
                             @"storeId" : self.storeId,
                             @"storeCityId" : @"469"};
    [CZJBaseDataInstance loadStoreInfo:@{@"storeId" : self.storeId} success:^(id json) {
        [self dealWithData:json];
        [self.myTableView reloadData];

    } fail:nil];
    
    [CZJBaseDataInstance loadStoreDetail:params success:^(id json) {
        
    } fail:nil];
}

- (void)dealWithData:(id)json
{
    NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    _storeDetailForm = [[CZJStoreDetailForm alloc]initWithDictionary:[dict valueForKey:@"store"]];
    _imgsArray = [dict valueForKey:@"imgs"];
    
    NSArray* activityTmpAry = [dict valueForKey:@"activitys"];
    for (int i = 0; i < activityTmpAry.count; i++)
    {
        CZJStoreDetailActivityForm* form = [[CZJStoreDetailActivityForm alloc]initWithDictionary:activityTmpAry[i]];
        [_activityArray addObject:form];
    }
    NSArray* bannersTmpAry = [dict valueForKey:@"banners"];
    for (int i = 0; i < bannersTmpAry.count; i++)
    {
        CZJStoreDetailBannerForm* form = [[CZJStoreDetailBannerForm alloc]initWithDictionary:bannersTmpAry[i]];
        [_bannerOneArray addObject:form];
    }
    NSArray* couponsTmpAry = [dict valueForKey:@"coupons"];
    for (int i = 0; i < couponsTmpAry.count; i++)
    {
        CZJShoppingCouponsForm* form = [[CZJShoppingCouponsForm alloc]initWithDictionary:couponsTmpAry[i]];
        [_couponsArray addObject:form];
    }
    NSArray* goodTypesTmpAry = [dict valueForKey:@"goodsTypes"];
    for (int i = 0; i < goodTypesTmpAry.count; i++)
    {
        
    }
    NSArray* serviceTypesTmpAry = [dict valueForKey:@"serviceTypes"];
    for (int i = 0; i < serviceTypesTmpAry.count; i++)
    {
        CZJStoreDetailTypesForm* form = [[CZJStoreDetailTypesForm alloc]initWithDictionary:serviceTypesTmpAry[i]];
        [_serviceTypesArray addObject:form];
    }
    NSArray* recommendTmpAry = [dict valueForKey:@"recommends"];
    for (int i = 0; i < recommendTmpAry.count; i++)
    {
        CZJSToreDetailGoodsAndServiceForm* form = [[CZJSToreDetailGoodsAndServiceForm alloc]initWithDictionary:recommendTmpAry[i]];
        [_recommendArray addObject:form];
    }
}

- (void)dealWithGoodsServiceData:(id)json
{
    [_serviceAndGoodsArray removeAllObjects];
     NSDictionary* dict = [CZJUtils DataFromJson:json];
    NSArray* goodsTmpAry = [dict valueForKey:@"msg"];
    for (int i = 0; i < goodsTmpAry.count; i++)
    {
        CZJSToreDetailGoodsAndServiceForm* form = [[CZJSToreDetailGoodsAndServiceForm alloc]initWithDictionary:goodsTmpAry[i]];
        [_serviceAndGoodsArray addObject:form];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    if (1 == section)
    {
        return _couponsArray.count > 0 ? 1 : 0;
    }
    if (2 == section)
    {
        return _bannerOneArray.count > 0 ? 1 : 0;
    }
    if (3 == section)
    {
        return _imgsArray.count;
    }
    if (4 == section)
    {
        if (_recommendArray.count > 0)
        {
            return _recommendArray.count/2 + 1;
        }
        
    }
    if (5 == section)
    {
        return _serviceAndGoodsArray.count/2 + 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        CZJStoreDetailHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailHeadCell" forIndexPath:indexPath];
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (2 == section) {
        return 44;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (2 == section)
    {
        UIView* headerView = [[UIView alloc]initWithSize:CGSizeMake(PJ_SCREEN_WIDTH, 44)];
        [headerView setBackgroundColor:[UIColor lightGrayColor]];
        [headerView setTag:500];
        
        return headerView;
    }
    return nil;
};


#pragma mark- ScrollViewDelegate
// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    bool isDraggingDown = (lastContentOffsetY - contentOffsetY) > 0 ;
    lastContentOffsetY = contentOffsetY;
    
    

    UIView* view = VIEWWITHTAG(self.myTableView, 500);
    CGRect frame = view.frame;
    DLog(@"frame:%f, contentOffsetY:%f",frame.origin.y, contentOffsetY);
    if ((contentOffsetY <= frame.origin.y - 64 && isDraggingDown)||
        (contentOffsetY >= frame.origin.y - 64 && !isDraggingDown))
    {
        self.topView.hidden = isDraggingDown;
    }
    
    if (contentOffsetY < 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [_naviBarView setAlpha:0.0];
        }];
        [_naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(0)];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            [_naviBarView setAlpha:1.0];
        }];
        
        float alphaValue = contentOffsetY * 0.5 / 200;
        if (alphaValue > 0.7)
        {
            alphaValue = 0.7;
        }
        [_naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(alphaValue)];
    }
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        default:
            break;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
