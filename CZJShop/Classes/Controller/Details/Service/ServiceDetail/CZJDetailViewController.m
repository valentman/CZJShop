//
//  CZJDetailViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailViewController.h"
#import "CZJNaviagtionBarView.h"
#import "NIDropDown.h"
#import "CZJBaseDataManager.h"
#import "MJRefresh.h"
#import "CZJPageControlView.h"
#import "CZJDetailForm.h"
#import "CZJDetailDescCell.h"
#import "CZJDetailPicShowCell.h"
#import "CZJChoosedProductCell.h"
#import "CZJCouponsCell.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJEvalutionHeaderCell.h"
#import "CZJStoreInfoHeaerCell.h"
#import "CZJStoreInfoCell.h"
#import "CZJHotRecommendCell.h"
#import "WyzAlbumViewController.h"
#import "UIImageView+WebCache.h"
#import "CZJChooseProductTypeController.h"
#import "CZJReceiveCouponsController.h"


@interface CZJDetailViewController ()
<NIDropDownDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate
>
{
    NIDropDown *dropDown;
    BOOL isScorllUp;
    
    CGFloat tableViewContentSizeHeight;
    BOOL isButtom;
    
    //当前页面数据
    NSMutableArray* _recommendServiceForms;         //推荐服务列表
    NSMutableArray* _couponForms;                   //领券列表
    CZJStoreInfoForm* _storeInfo;                   //服务门店信息
    CZJDetailEvalInfo* _evalutionInfo;              //服务评价简介
    CZJServiceDetail* _serviceDetail;               //服务详情信息
    CZJGoodsDetail* _goodsDetail;
    
    CGRect popViewRect;
}
@property (weak, nonatomic) IBOutlet UIView *borderLineView;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *detailNaviBarView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) UITableView* detailTableView;


@end

@implementation CZJDetailViewController
@synthesize storeItemPid = _storeItemPid;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getDataFromServer];
}

- (void)initDatas
{
    _recommendServiceForms = [NSMutableArray array];
    _couponForms = [NSMutableArray array];
}

- (void)initViews
{
    self.borderLineView.layer.borderWidth = 0.1;
    self.borderLineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //顶部导航栏
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    CGRect viewBounds = CGRectMake(0, 0, mainViewBounds.size.width, 52);
    [self.detailNaviBarView initWithFrame:viewBounds AndType:CZJNaviBarViewTypeDetail].delegate = self;;
    [self.detailNaviBarView setBackgroundColor:RGBA(239, 239, 239, 0)];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBACOLOR(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    
    //背景Scrollview
    self.myScrollView.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT-20 -50);
    self.myScrollView.contentSize = CGSizeMake(PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-90)*2);
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.scrollEnabled = NO;
    self.myScrollView.delegate = self;
    self.myScrollView.tag = 1002;
    self.myScrollView.showsVerticalScrollIndicator = NO;
    
    //详情TableView
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -20, PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-70)) style:UITableViewStylePlain];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    _detailTableView.backgroundColor = [UIColor lightGrayColor];
    _detailTableView.showsVerticalScrollIndicator = NO;
    NSArray* nibArys = @[ @"CZJDetailDescCell",
                          @"CZJDetailPicShowCell",
                          @"CZJChoosedProductCell",
                          @"CZJCouponsCell",
                          @"CZJEvalutionDescCell",
                          @"CZJEvalutionFooterCell",
                          @"CZJEvalutionHeaderCell",
                          @"CZJStoreInfoCell",
                          @"CZJHotRecommendCell",
                          @"CZJStoreInfoHeaerCell",
                          ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.detailTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    //设置UITableView 上拉加载
    _detailTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //上拉，执行对应的操作---改变底层滚动视图的滚动到对应位置
        //设置动画效果
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            if (!isButtom) {
                tableViewContentSizeHeight= self.detailTableView.contentOffset.y;
                isButtom = YES;
                DLog(@"offset:%f", tableViewContentSizeHeight);
            }
        } completion:^(BOOL finished) {
            //结束加载
            [_detailTableView.footer endRefreshing];
        }];
    }];
    _detailTableView.tag = 1001;
    [self.myScrollView addSubview:_detailTableView];
    
    //图文详情页
    CZJPageControlView* webVie = [[CZJPageControlView alloc]initWithFrame:CGRectMake(0, (PJ_SCREEN_HEIGHT-90), PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-110))];
    [self.myScrollView addSubview:webVie];
    
}

- (void)getDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        [self dealWithData];
        [self.detailTableView reloadData];
    };
    
    [CZJBaseDataInstance loadDetailsWithType:self.detaiViewType
                             AndStoreItemPid:self.storeItemPid
                                     Success:successBlock
                                        fail:^{}];
}

- (void)dealWithData
{
    _recommendServiceForms = [[CZJBaseDataInstance detailsForm] recommendServiceForms];
    _couponForms = [[CZJBaseDataInstance detailsForm] couponForms];
    _storeInfo = [[CZJBaseDataInstance detailsForm] storeInfo];
    _evalutionInfo = [[CZJBaseDataInstance detailsForm] evalutionInfo];
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        _goodsDetail = [[CZJBaseDataInstance detailsForm] goodsDetail];
    }
    else if (CZJDetailTypeService == self.detaiViewType)
    {
        _serviceDetail = [[CZJBaseDataInstance detailsForm] serviceDetail];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- CZJNaviBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = [[NSArray alloc] init];
            arr = [NSArray arrayWithObjects:@{@"消息" : @"prodetail_icon_msg"}, @{@"首页":@"prodetail_icon_home"}, @{@"分享" :@"prodetail_icon_share"},nil];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 150);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr];
                dropDown.delegate = self;
            }
        }
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
        }];
    }
    complete();
    
}

#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
        DLog(@"消息");
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        DLog(@"首页");
    }
    if ([btnStr isEqualToString:@"分享"])
    {
        DLog(@"分享");
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (4 == section)
    {
        return 3;
    }
    if (5 == section)
    {
        return 2;
    }
    if (CZJDetailTypeService == self.detaiViewType && 3 == section)
    {//服务详情界面去掉已选cell
        return 0;
    }
    if (2 == section && _couponForms.count <= 0)
    {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //依据不同的内容加载不同类型的Cell
    switch (indexPath.section) {
        case 0:
        {//图片展示
            CZJDetailPicShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailPicShowCell" forIndexPath:indexPath];
            switch (self.detaiViewType)
            {
                case CZJDetailTypeGoods:
                    if (_goodsDetail.imgs.count > 0 && !cell.isInit) {
                        [cell someMethodNeedUse:indexPath DataModel:_goodsDetail.imgs];
                        cell.delegate = self;
                    }
                    break;
                case CZJDetailTypeService:
                    if (_serviceDetail.imgs.count > 0 && !cell.isInit) {
                        [cell someMethodNeedUse:indexPath DataModel:_serviceDetail.imgs];
                        cell.delegate = self;
                    }
                    break;
                    
                default:
                    break;
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 1:
        {//详情描述
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell" forIndexPath:indexPath];
            cell.miaoShaLabel.hidden = YES;
            cell.leftTimeLabel.hidden = YES;
            
//            [cell.goShopImage setImage:[UIImage imageNamed:@""]];
//            cell.miaoShaLabel.text = _serviceDetail.;
//            cell.leftTimeLabel;
            switch (self.detaiViewType)
            {
                case CZJDetailTypeGoods:
                {
                    NSString* priceStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.originalPrice];
                    [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:priceStr]];
                    CGSize labelSize = [CZJUtils calculateTitleSizeWithString:priceStr WithFont:BOLDSYSTEMFONT(22)];
                    cell.labelLayoutConst.constant = labelSize.width + 5;
                    cell.currentPriceLabel.text = [NSString stringWithFormat:@"￥%@", _goodsDetail.currentPrice];
                    cell.purchaseCountLabel.text = _goodsDetail.purchaseCount;
                    
                    cell.productNameLabel.text = _goodsDetail.itemName;
                    CGRect productRect = cell.productNameLabel.frame;
                    CGRect prolabelSize = [_goodsDetail.itemName boundingRectWithSize:CGSizeMake(PJ_SCREEN_WIDTH - 45, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:cell.productNameLabel.font,NSFontAttributeName, nil] context:nil];

                    cell.productNameLayoutHeight.constant = prolabelSize.size.height;

                    if (_goodsDetail.skillFlag)
                    {
                        cell.miaoShaLabel.hidden = NO;
                        cell.leftTimeLabel.hidden = NO;
                    }
                }
                    break;
                case CZJDetailTypeService:
                    [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:_serviceDetail.originalPrice]];
                    cell.currentPriceLabel.text = _serviceDetail.currentPrice;
                    cell.purchaseCountLabel.text = _serviceDetail.purchaseCount;
                    cell.productNameLabel.text = _serviceDetail.itemName;
                    break;
                    
                default:
                    break;
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;

        case 2:
        {//领券信息
            CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
            if (cell && _couponForms.count > 0 && !cell.isInit)
            {
                [cell initWithCouponDatas:_couponForms];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;

        case 3:
        {
            CZJChoosedProductCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJChoosedProductCell" forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.sku = _goodsDetail.sku;
            cell.storeItemPid = _goodsDetail.storeItemPid;
            cell.productType.text = _goodsDetail.sku.skuValues;
            cell.counterKey = _goodsDetail.counterKey;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
            
        case 4:
        {//评论数据
            if (0 == indexPath.row) {
                CZJEvalutionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionHeaderCell" forIndexPath:indexPath];

                if (_evalutionInfo) {
                    cell.goodRateLabel.text = _evalutionInfo.goodRate;
                    cell.personCountLabel.text = _evalutionInfo.evalCount;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
                if (_evalutionInfo) {
                    cell.evalWriter.text = ((CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1]).evalName;
                    cell.evalTime.text = ((CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1]).evalTime;
                    cell.evalContent.text = ((CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1]).evalDesc;
                    [cell.addtionnalImage sd_setImageWithURL:[NSURL URLWithString:((CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1]).imgs[0]]
                                            placeholderImage:nil];
                    [cell setStar:[((CZJEvalutionsForm*)_evalutionInfo.evalList[indexPath.row - 1]).evalStar intValue]];
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (2 == indexPath.row)
            {
                CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
                [cell setVisibleView:kLookAllEvalView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
        case 5:
        {//门店信息介绍
            if (0 == indexPath.row)
            {
                CZJStoreInfoHeaerCell *cell = (CZJStoreInfoHeaerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoHeaerCell"  forIndexPath:indexPath];
                if (_storeInfo)
                {
                    [cell.storeImage sd_setImageWithURL:[NSURL URLWithString:_storeInfo.logo]
                                            placeholderImage:nil];
                    cell.storeName.text = _storeInfo.storeName;
                    cell.storeAddr.text = _storeInfo.storeAddr;
                    cell.storeAddrLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.storeNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else if (1 == indexPath.row)
            {
                CZJStoreInfoCell *cell = (CZJStoreInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoCell" forIndexPath:indexPath];
                if (_storeInfo)
                {
                    cell.attentionNumber.text = _storeInfo.attentionCount;
                    cell.goodsNumber.text = _storeInfo.goodsCount;
                    cell.serviceNumber.text = _storeInfo.serviceCount;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            
        }
            break;
            
        case 6:
        {//热门推荐
           
            CZJHotRecommendCell *cell = (CZJHotRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJHotRecommendCell" forIndexPath:indexPath];
            if (!cell.isInit && _recommendServiceForms.count > 0) {
                [cell setHotRecommendDatas:_recommendServiceForms];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            
        default:
            return nil;
            break;
    }
    return nil;
    
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.section)
    {
        popViewRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        UIWindow *window = [[UIWindow alloc] initWithFrame:popViewRect];
        window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        window.windowLevel = UIWindowLevelNormal;
        window.hidden = NO;
        [window makeKeyAndVisible];
        
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        window.rootViewController = receiveCouponsController;
        self.window = window;
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [view addGestureRecognizer:tap];
        [self.view addSubview:view];
        self.upView = view;
        self.upView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.window.frame =  CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
            self.upView.alpha = 1.0;
        } completion:nil];
        
        __weak typeof(self) weak = self;
        [receiveCouponsController setCancleBarItemHandle:^{
            [UIView animateWithDuration:0.5 animations:^{
                weak.window.frame = popViewRect;
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
    if (3 == indexPath.section)
    {
        CZJChoosedProductCell* cell = (CZJChoosedProductCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        popViewRect =  CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        UIWindow *window = [[UIWindow alloc] initWithFrame:popViewRect];
        window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        window.windowLevel = UIWindowLevelNormal;
        window.hidden = NO;
        [window makeKeyAndVisible];
        
        CZJChooseProductTypeController *chooseProductTypeController = [[CZJChooseProductTypeController alloc] init];
        window.rootViewController = chooseProductTypeController;
        self.window = window;
        chooseProductTypeController.counterKey = cell.counterKey;
        chooseProductTypeController.storeItemPid = cell.storeItemPid;
        [chooseProductTypeController getSKUDataFromServer];
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [view addGestureRecognizer:tap];
        [self.view addSubview:view];
        self.upView = view;
        self.upView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.window.frame = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
            self.upView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)tapAction{
    [UIView animateWithDuration:0.5 animations:^{
        self.window.frame = popViewRect;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 375;
            break;
        case 1:
        {
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell"];
            CGRect productRect = cell.productNameLabel.frame;
            DLog(@"width:%f",productRect.size.width);
            CGRect prolabelSize = [_goodsDetail.itemName boundingRectWithSize:CGSizeMake(PJ_SCREEN_WIDTH - 45, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:SYSTEMFONT(16),NSFontAttributeName, nil] context:nil];
            if (CZJDetailTypeGoods == self.detaiViewType &&
                _goodsDetail.skillFlag)
            {
                return 88 + prolabelSize.size.height;
                
            }
            else
            {
                int height = prolabelSize.size.height;
                DLog(@"height:%d",height);
                return 65 + prolabelSize.size.height;
            }
        }
            break;
        case 2:
            return 96;
            break;
        case 3:
            return 46;
            break;
        case 4:
            if (0 == indexPath.row) {
                return 46;
            }
            if (1 == indexPath.row) {
                //这里是动态改变的，暂时设一个固定值
                return 160;
            }
            if (2 == indexPath.row)
            {
                return 64;
            }
            break;
        case 5:
            if (0 == indexPath.row)
            {
                return 81;
            }
            if (1 == indexPath.row)
            {
                return 131;
            }
            break;
        case 6:
            return 404;
            break;
            
        default:
            return 200;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}



#pragma mark- ScrollViewDelegate
// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DLog();
    float contentOffsetY = [scrollView contentOffset].y;
    DLog(@"tag:%ld, %f",scrollView.tag, contentOffsetY);
}

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    DLog(@"tag:%ld, %f",scrollView.tag, contentOffsetY);
    
    if (1001 == scrollView.tag && contentOffsetY <=0) {
        [self.detailNaviBarView setBackgroundColor:RGBA(239, 239, 239, 0)];
    }
    else
    {
        float alphaValue = contentOffsetY / 100;
        if (alphaValue > 1)
        {
            alphaValue = 1;
        }
        [self.detailNaviBarView setBackgroundColor:RGBA(239, 239, 239, alphaValue)];
    }

}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    float contentOffsetY = [scrollView contentOffset].y;
    
    DLog(@"tag:%ld, %f",scrollView.tag, contentOffsetY);
    if (isButtom && 1001 == scrollView.tag && contentOffsetY >= tableViewContentSizeHeight + 50)
    {
        [self.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-130)) animated:true];
        self.myScrollView.scrollEnabled = YES;
        isButtom = NO;
        
    }
    if (1002 == scrollView.tag && targetContentOffset->y == 576)
    {
        targetContentOffset->y = targetContentOffset->y + 26;
    }
    DLog(@"velocity.y:%f, offset:%f",velocity.y, targetContentOffset->y);
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    DLog();
}

// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    DLog();
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    DLog();
    float contentOffsetY = [scrollView contentOffset].y;
    if (1002 == scrollView.tag && contentOffsetY == 0)
    {
        self.myScrollView.scrollEnabled = NO;
        [self.myScrollView setContentOffset:CGPointMake(0, -20) animated:true];
        isButtom = NO;
    }
    if (1002 == scrollView.tag && contentOffsetY == 576) {
        [self.myScrollView setContentOffset:CGPointMake(0, 602) animated:true];
    }

}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    DLog();
}

// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return true;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    DLog();
}


#pragma mark- CZJImageTouchViewDelegate
- (void)showDetailInfoWithIndex:(NSInteger)index
{
    WyzAlbumViewController *wyzAlbumVC = [[WyzAlbumViewController alloc]init];
    wyzAlbumVC.currentIndex =index;//这个参数表示当前图片的index，默认是0
    //用url
    wyzAlbumVC.imgArr = _serviceDetail.imgs;
    //进入动画
    [self presentViewController:wyzAlbumVC animated:YES completion:^{
    }];
}

@end
