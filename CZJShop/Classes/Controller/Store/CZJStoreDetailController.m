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
#import "CZJGoodsRecommendCell.h"
#import "CZJGoodsRecoCellHeader.h"
#import "CZJStoreDetailMenuCell.h"
#import "CZJCouponsCell.h"
#import "CZJAdBanerCell.h"
#import "CZJBaseDataManager.h"
#import "UIImageView+WebCache.h"
#import "CZJShoppingCartForm.h"
#import "CZJStoreDetailForm.h"
#import "CZJDetailForm.h"
#import "HomeForm.h"

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
                         @"CZJStoreDescribeTwoCell",
                         @"CZJGoodsRecommendCell",
                         @"CZJAdBanerCell",
                         @"CZJCouponsCell",
                         @"CZJGoodsRecoCellHeader",
                         @"CZJStoreDetailMenuCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.topView = [CZJUtils getXibViewByName:@"CZJStoreDetailMenuCell"];
    self.topView.hidden = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
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
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self.myTableView reloadData];

    } fail:nil];
    
    [CZJBaseDataInstance loadStoreDetail:params success:^(id json) {
        CZJGeneralBlock block = ^()
        {
            [self dealWithGoodsServiceData:json];
        };
        [CZJUtils performBlock:block afterDelay:0.5];
        
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
        CZJCouponForm* form = [[CZJCouponForm alloc]initWithDictionary:couponsTmpAry[i]];
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
    NSMutableArray* serviceGoodsTmpAry = [NSMutableArray array];
    for (int i = 0; i < goodsTmpAry.count; i++)
    {
        GoodsRecommendForm* form = [[GoodsRecommendForm alloc]initWithDictionary:goodsTmpAry[i]];
        [serviceGoodsTmpAry addObject:form];
    }
    float count = (float)serviceGoodsTmpAry.count;
    float count2 = ceilf(count/2);
    [_serviceAndGoodsArray removeAllObjects];
    for (int i  = 0; i < count2; i++)
    {
        NSMutableArray* array = [NSMutableArray array];
        [_serviceAndGoodsArray addObject:array];
    }
    for (int i = 0; i < count; i++) {
        int index = i / 2;
        [_serviceAndGoodsArray[index] addObject:serviceGoodsTmpAry[i]];
    }
    if (_serviceAndGoodsArray.count > 0)
    {
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
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
        return ceilf(_recommendArray.count/2) > 0 ? ceilf(_recommendArray.count/2) + 1 : 0;
    }
    if (5 == section)
    {
        return _serviceAndGoodsArray.count > 0 ? _serviceAndGoodsArray.count + 2 : 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJStoreDetailHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailHeadCell" forIndexPath:indexPath];
            cell.storeAddrLabel.text = _storeDetailForm.storeAddr;
            cell.storeNameLabel.text = _storeDetailForm.storeName;
            cell.attentionCountLabel.text = _storeDetailForm.attentionCount;
            [cell.attentionBtn setImage:IMAGENAMED(_storeDetailForm.attentionFlag ? @"shop_icon_guanzhu_sel" : @"shop_icon_guanzhu") forState:UIControlStateNormal];
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJStoreDescribeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeCell" forIndexPath:indexPath];
            cell.envirmentScoreLabel.text = _storeDetailForm.environmentScore;
            cell.describeScoreLabel.text = _storeDetailForm.descScore;
            cell.deliveryScoreLabel.text = _storeDetailForm.deliveryScore;
            cell.serviceScoreLabel.text = _storeDetailForm.serviceScore;
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJStoreDescribeTwoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDescribeTwoCell" forIndexPath:indexPath];
            cell.serviceLabel.text = _storeDetailForm.serviceCount;
            cell.promotionLabel.text = _storeDetailForm.promotionCount;
            cell.setMenuLabel.text = _storeDetailForm.setmenuCount;
            cell.goodsLabel.text = _storeDetailForm.goodsCount;
            return cell;
        }
    }
    if (1 == indexPath.section && 0 == indexPath.row)
    {//领券
        CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
        if (cell && _couponsArray.count > 0 && !cell.isInit)
        {
            [cell initWithCouponDatas:_couponsArray];
        }
        return cell;
    }
    if (2 == indexPath.section && 0 == indexPath.row)
    {//广告一
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        [cell initBannerOneWithDatas:_bannerOneArray];
        return cell;
    }
    if (3 == indexPath.section)
    {//广告二
        CZJAdBanerCell *cell = (CZJAdBanerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJAdBanerCell" forIndexPath:indexPath];
        [cell initBannerWithImg:_imgsArray[indexPath.row]];
        return cell;
    }
    if (4 == indexPath.section)
    {//推荐商品或服务
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            return headerView;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGoodsRecoCellHeader* headerView = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecoCellHeader" forIndexPath:indexPath];
            headerView.backgroundColor = [UIColor clearColor];
            headerView.backgroundView.backgroundColor = [UIColor clearColor];
            headerView.recoImg.hidden = YES;
            headerView.recoLabel.hidden = YES;
            headerView.recoMenuLabel.hidden = NO;
            headerView.recoMenuLabel.text = @"服务和商品";
            headerView.recoViewLayoutWidth.constant = [CZJUtils calculateTitleSizeWithString:@"服务和商品" WithFont:headerView.recoMenuLabel.font].width;
            return headerView;
        }
        else if (1 == indexPath.row)
        {
            CZJStoreDetailMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreDetailMenuCell" forIndexPath:indexPath];
            [cell setTag:500];
            return cell;
        }
        else
        {
            CZJGoodsRecommendCell* cell = (CZJGoodsRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJGoodsRecommendCell" forIndexPath:indexPath];
            if (cell && _serviceAndGoodsArray.count > 0) {
                [cell initGoodsRecommendWithDatas:_serviceAndGoodsArray[indexPath.row - 2]];
            }
            return cell;
        }
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 180;
        }
        if (1 == indexPath.row)
        {
            return 60;
        }
        if (2 == indexPath.row)
        {
            return 139;
        }
    }
    if (1 == indexPath.section)
    {
        return 50;
    }
    if (2 == indexPath.section)
    {
        return 100;
    }
    if (3 == indexPath.section)
    {
        return 150;
    }
    if (4 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 35;
        }
        if (1 == indexPath.row)
        {
            return 245;
        }
    }
    if (5 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 35;
        }
        else if (1 == indexPath.row)
        {
            return 44;
        }
        else
        {
            return 245;
        }
    }
    return 180;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
