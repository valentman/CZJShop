//
//  CZJDetailViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailViewController.h"
#import "NIDropDown.h"
#import "CZJBaseDataManager.h"
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
#import "CZJOrderTypeExpandCell.h"
#import "WyzAlbumViewController.h"
#import "CZJChooseProductTypeController.h"
#import "CZJPicDetailBaseController.h"
#import "CZJGoodsDetailForm.h"
#import "CZJStoreForm.h"
#import "CZJCommitOrderController.h"
#import "CZJPromotionController.h"
#import "CZJStoreDetailController.h"
#import "CZJUserEvalutionController.h"
#import "CZJAddedEvalutionCell.h"
#import "CZJReceiveCouponsController.h"
#import "CZJGeneralCell.h"
#import "CZJMiaoShaControlHeaderCell.h"

#define kTagScrollView 1002
#define kTagTableView 1001

@interface CZJDetailViewController ()
<
NIDropDownDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate,
CZJStoreInfoHeaerCellDelegate,
CZJChooseProductTypeDelegate
>
{
    NIDropDown *dropDown;
    BOOL isScorllUp;
    
    CGFloat tableViewContentSizeHeight;
    __block BOOL isButtom;
    
    //当前页面数据
    CZJGoodsDetailForm* goodsDetailForm;            //详情界面总数据
    CZJStoreInfoForm* _storeInfo;                   //服务门店信息
    CZJDetailEvalInfo* _evalutionInfo;              //服务评价简介
    CZJGoodsDetail* _goodsDetail;                   //商品信息
    NSArray* _couponForms;                          //领券列表
    NSArray* _recommendServiceForms;                //推荐服务列表
    
    CZJChoosedProductCell* chooosedProductCell;     //已选商品cell，定义成成员变量是为了方便传值
    CZJMiaoShaControlHeaderCell* miaoShaCell;       //秒杀栏
    NSInteger _timestamp;                           //秒杀倒计时
    NSTimer* timer;                                 //秒杀定时器
    
    NSMutableArray* _settleOrderAry;
    NSInteger buyCount;                             //当前商品已选规格个数
}
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIView *borderLineView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *shoppingCartView;
@property (weak, nonatomic) IBOutlet UIButton *addProductToShoppingCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyImeditelyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderLineLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProductToWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *immediatelyBuyWidth;
@property (weak, nonatomic) IBOutlet UIView *serviceView;

@property (strong, nonatomic) UITableView* detailTableView;

- (IBAction)immediatelyBuyAction:(id)sender;
- (IBAction)addProductToShoppingCartAction:(id)sender;
- (IBAction)attentionAction:(id)sender;
- (IBAction)contactServiceAction:(id)sender;
- (IBAction)storeAction:(id)sender;


@end

@implementation CZJDetailViewController
@synthesize storeItemPid = _storeItemPid;

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeDetail];
    [self initDatas];
    [self initViews];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils performBlock:^{
        [self getDataFromServer];
    } afterDelay:0.5];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.naviBarView refreshShopBadgeLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registNotification];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiRefreshDetailView object:nil];
    [[NSNotificationCenter  defaultCenter] removeObserver:self name:kCZJNotifiPicDetailBack object:nil];
}

- (void)initDatas
{
    _recommendServiceForms = [NSArray array];
    _couponForms = [NSArray array];
    _settleOrderAry = [NSMutableArray array];
    buyCount = 1;
}

- (void)initViews
{
    self.borderLineLayoutHeight.constant = 0.5;
    self.borderLineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02") forState:UIControlStateNormal];
    [self.attentionBtn setImage:IMAGENAMED(@"prodetail_icon_guanzhu02_sel") forState:UIControlStateSelected];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    
    //背景Scrollview
    self.myScrollView.contentSize = CGSizeMake(PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-50)*2 - 64);
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.scrollEnabled = NO;
    self.myScrollView.delegate = self;
    self.myScrollView.tag = kTagScrollView;
    self.myScrollView.showsVerticalScrollIndicator = NO;
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    
    //详情TableView
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-50)) style:UITableViewStylePlain];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    _detailTableView.showsVerticalScrollIndicator = NO;
    _detailTableView.backgroundColor = [UIColor whiteColor];
    _detailTableView.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
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
                          @"CZJOrderTypeExpandCell",
                          @"CZJAddedEvalutionCell"
                          ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.detailTableView registerNib:nib forCellReuseIdentifier:cells];
    }

    _detailTableView.tag = kTagTableView;
    self.detailTableView.tableFooterView = [[UIView alloc] init];
    [self.myScrollView addSubview:_detailTableView];
    [self.detailTableView reloadData];
    self.shoppingCartView.hidden = YES;
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDetailData:) name:kCZJNotifiRefreshDetailView  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(picDetailViewBack:) name:kCZJNotifiPicDetailBack object:nil];
}

- (void)reloadDetailData:(NSNotification*)notif
{
    self.storeItemPid = [notif.userInfo objectForKey:@"storeItemPid"];
    buyCount = [[notif.userInfo objectForKey:@"buycount"] integerValue];
    [self getDataFromServer];
}

- (void)picDetailViewBack:(NSNotification*)notif
{
    [self.myScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)getDataFromServer
{
    __weak typeof(self) weak = self;
    CZJSuccessBlock successBlock = ^(id json)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        goodsDetailForm = [CZJGoodsDetailForm objectWithKeyValues:dict];
        DLog(@"goodsDetailForm:%@",[goodsDetailForm.keyValues description]);
        //根据购买类型显示底部“加入购物车”与否（0表示是商品，显示“加入购物车”，1则表示服务，只显示“立即购买”）
        if (0 == [goodsDetailForm.goods.buyType floatValue])
        {
            self.addProductToWidth.constant = (iPhone4 || iPhone5) ? 80 : 100;
            self.immediatelyBuyWidth.constant = (iPhone4 || iPhone5) ? 80 : 100;;
        }
        if (1 == [goodsDetailForm.goods.buyType floatValue])
        {
            self.addProductToWidth.constant = 0;
            self.immediatelyBuyWidth.constant = (iPhone4 || iPhone5) ? 130 : 160;;
        }
        
        [self dealWithData];
        [self.detailTableView reloadData];
        self.shoppingCartView.hidden = NO;
        //获取热门商品或服务
        [self getHotRecommendDataFromServer];
        
        //图文详情页
        CZJPicDetailController *FController = [[CZJPicDetailController alloc]init];
        FController.detaiViewType = self.detaiViewType;
        CZJBuyNoticeController *SController = [[CZJBuyNoticeController alloc]init];
        SController.detaiViewType = self.detaiViewType;
        CZJAfterServiceController *TController = [[CZJAfterServiceController alloc]init];
        TController.detaiViewType = self.detaiViewType;
        CZJApplicableCarController *AController = [[CZJApplicableCarController alloc]init];
        AController.detaiViewType = self.detaiViewType;
        
        CZJPageControlView* webVie = [[CZJPageControlView alloc]initWithFrame:CGRectMake(0, (PJ_SCREEN_HEIGHT-50), PJ_SCREEN_WIDTH, (PJ_SCREEN_HEIGHT-114)) andPageIndex:kPagePicDetail];
        webVie.backgroundColor = CZJNAVIBARBGCOLOR;
        [webVie setTitleArray:@[@"图文详情",@"购买须知",@"包装售后",@"适用车型"] andVCArray:@[FController,SController,TController,AController]];
        [self.myScrollView addSubview:webVie];
    };
    NSDictionary* param = @{@"storeItemPid":self.storeItemPid, @"promotionPrice":self.promotionPrice, @"promotionType":[NSString stringWithFormat:@"%ld",self.promotionType]};
    NSString* apiUrl;
    if (CZJDetailTypeGoods == _detaiViewType)
    {
        apiUrl = kCZJServerAPIGoodsDetail;
    }
    else if (CZJDetailTypeService == _detaiViewType)
    {
        apiUrl = kCZJServerAPIServiceDetail;
    }
    
    [CZJBaseDataInstance generalPost:param success:successBlock  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getDataFromServer];
        }];
    } andServerAPI:apiUrl];
}

- (void)getHotRecommendDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSArray* dict = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
        DLog(@"hotrecommend:%@",[dict description]);
        _recommendServiceForms = [CZJStoreServiceForm objectArrayWithKeyValuesArray:dict];
        [self.detailTableView reloadData];
        
        //推荐商品获取完成后再计算TableView的contentSize
        DLog(@"contentSizeHeight:%f, frameHeight:%f",self.detailTableView.mj_contentH,self.detailTableView.mj_h)
        tableViewContentSizeHeight = self.detailTableView.mj_contentH - self.detailTableView.mj_h;
    };
    
    [CZJBaseDataInstance loadDetailHotRecommendWithType:self.detaiViewType
                                             andStoreId:_storeInfo.storeId
                                                Success:successBlock
                                                   fail:^{}];
}

- (void)dealWithData
{
    _couponForms = goodsDetailForm.coupons;
    _storeInfo = goodsDetailForm.store;
    _evalutionInfo = goodsDetailForm.evals;
    _goodsDetail = goodsDetailForm.goods;
    [USER_DEFAULT setObject:_goodsDetail.storeItemPid forKey:kUserDefaultDetailStoreItemPid];
    [USER_DEFAULT setObject:_goodsDetail.itemCode forKey:kUserDefaultDetailItemCode];
    self.attentionBtn.selected = _goodsDetail.attentionFlag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + (goodsDetailForm == nil ? 0 : 6);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (2 == section && _couponForms.count <= 0)
    {
        return 0;
    }
    if (4 == section)
    {
        return goodsDetailForm.promotions.count > 0 ? 1 : 0;
    }
    if (5 == section)
    {
        return _evalutionInfo.evalList.count;
    }
    if (6 == section)
    {
    
        return _goodsDetail.selfFlag ? 0 : 2;
    }
    if (CZJDetailTypeService == self.detaiViewType && 3 == section)
    {//服务详情界面去掉已选cell
        return 0;
    }
    if (7 == section)
    {
        return _recommendServiceForms.count > 0 ? 1 : 0;
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
            if (_goodsDetail.imgs.count > 0 && !cell.isInit) {
                [cell someMethodNeedUse:indexPath DataModel:_goodsDetail.imgs];
                cell.delegate = self;
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
            break;
            
        case 1:
        {//详情描述
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell" forIndexPath:indexPath];
            //商品名称
            cell.productNameLabel.text = _goodsDetail.itemName;
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:_goodsDetail.itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 45];
            cell.productNameLayoutHeight.constant = prolabelSize.height;
            
            //商品当前价格
            NSString* currentStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.currentPrice == nil ? @"" :_goodsDetail.currentPrice];
            cell.currentPriceLabel.text = currentStr;
            CGSize labelSize = [CZJUtils calculateTitleSizeWithString:currentStr WithFont:BOLDSYSTEMFONT(22)];
            cell.labelLayoutConst.constant = labelSize.width + 5;
            
            //是否到店标示
            cell.goShopImage.hidden = !goodsDetailForm.goods.goHouseFlag;
            
            //如果是秒杀商品有原价
            if (CZJGoodsPromotionTypeMiaoSha == _promotionType)
            {
                //商品原价
                NSString* originStr = [NSString stringWithFormat:@"￥%@", _goodsDetail.originalPrice == nil ? @"" :_goodsDetail.originalPrice];
                [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:originStr]];
                CGSize originSize = [CZJUtils calculateTitleSizeWithString:originStr WithFont:SYSTEMFONT(12)];
                cell.originPriceWidth.constant = originSize.width + 5;
                
                //秒杀栏
                miaoShaCell = [CZJUtils getXibViewByName:@"CZJMiaoShaControlHeaderCell"];
                miaoShaCell.miaoshaIconLeading.constant = 20;
                miaoShaCell.miaoShaTypeLabel.hidden = YES;
                miaoShaCell.frame = CGRectMake(0, 65 + ((prolabelSize.height < 15) ? 15 : prolabelSize.height), PJ_SCREEN_WIDTH, 35);
                [cell addSubview:miaoShaCell];
                [self setTimestamp:_miaoShaInterval];
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
            return cell;
        }
            break;

        case 3:
        {//已选规格
            chooosedProductCell = [tableView dequeueReusableCellWithIdentifier:@"CZJChoosedProductCell" forIndexPath:indexPath];
            chooosedProductCell.indexPath = indexPath;
            chooosedProductCell.goodsDetail = _goodsDetail;
            chooosedProductCell.storeItemPid = _goodsDetail.storeItemPid;
            chooosedProductCell.productType.text = [NSString stringWithFormat:@"%@ %ld个",[_goodsDetail.sku.skuValues isEqualToString:@"null"]? @"" : _goodsDetail.sku.skuValues,buyCount];
            chooosedProductCell.counterKey = _goodsDetail.counterKey;
            [chooosedProductCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return chooosedProductCell;
        }
            break;
            
        case 4:
        {//促销
            CZJCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
            cell.arrowImg.hidden = YES;
            cell.couponNameLabel.text = @"促销";
            cell.couponScrollView.clipsToBounds = NO;
            if (goodsDetailForm.promotions.count > 0)
            {
                NSInteger range = goodsDetailForm.promotions.count > 2 ? 2 : goodsDetailForm.promotions.count;
                for (int i = 0 ; i < range; i++)
                {
                    CZJPromotionItemForm* promotionItem = (CZJPromotionItemForm*)goodsDetailForm.promotions[i];
                    CZJGeneralCell* promotionItemCell = [CZJUtils getXibViewByName:@"CZJGeneralCell"];
                    NSString* imageName;
                    if ([promotionItem.type integerValue] == 0)
                    {
                        imageName = @"label_icon_jian";
                    }
                    else
                    {
                        imageName = @"label_icon_zengpin";
                    }
                    promotionItemCell.imageViewHeight.constant = 15;
                    promotionItemCell.imageViewWidth.constant = 30;
                    [promotionItemCell.headImgView setImage:IMAGENAMED(imageName)];
                    promotionItemCell.nameLabelWidth.constant = PJ_SCREEN_WIDTH - 130;
                    promotionItemCell.nameLabel.text = promotionItem.desc;
                    promotionItemCell.nameLabel.font = SYSTEMFONT(13);
                    promotionItemCell.nameLabel.textColor = RGB(109, 109, 109);
                    CGRect cellRect = CGRectMake(-20, 15 + i * 30, PJ_SCREEN_WIDTH - 40, 15);
                    promotionItemCell.frame = cellRect;
                    
                    UIButton* tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [tapButton addTarget:self action:@selector(tapPromotionCell:) forControlEvents:UIControlEventTouchUpInside];
                    tapButton.frame = CGRectMake(0, -5, promotionItemCell.frame.size.width, promotionItemCell.frame.size.height + 10);
                    tapButton.tag = [promotionItem.type integerValue];
                    [promotionItemCell addSubview:tapButton];
                    
                    [cell.couponScrollView addSubview:promotionItemCell];
                }
            }
            return cell;
        }
            break;
            
        case 5:
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
            else if (_evalutionInfo.evalList.count + 1 > indexPath.row)
            {
                CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
                if (_evalutionInfo.evalList.count > 0)
                {
                    CZJEvaluateForm* evalutionForm  = (CZJEvaluateForm*)_evalutionInfo.evalList[indexPath.row - 1];
                    cell.evalWriter.text = evalutionForm.name;
                    cell.evalTime.text = evalutionForm.evalTime;
                    
                    
                    cell.evalContent.text = evalutionForm.message;
                    CGSize contenSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                    cell.evalContentLayoutHeight.constant = contenSize.height;
                    
                    for (int i = 0; i < evalutionForm.evalImgs.count; i++)
                    {
                        UIImageView* evaluateImage = [[UIImageView alloc]init];
                        [evaluateImage sd_setImageWithURL:[NSURL URLWithString:evalutionForm.evalImgs[i]] placeholderImage:DefaultPlaceHolderImage];
                        CGRect iamgeRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 10) size:CGSizeMake(78, 78) index:i divide:Divide];
                        evaluateImage.frame = iamgeRect;
                        [cell.picView addSubview:evaluateImage];
                    }
                    [cell setStar:[evalutionForm.score intValue]];
                    
                    
                    if ([evalutionForm.added boolValue])
                    {
                        CGSize contentSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                        NSInteger row = evalutionForm.evalImgs.count / Divide + 1;
                        NSInteger cellHeight = 60 + (contentSize.height > 20 ? contentSize.height : 20) + row * 88;
                        
                        
                        CZJAddedEvalutionCell* addedCell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddedEvalutionCell" forIndexPath:indexPath];
                        addedCell.addedTimeLabel.text = evalutionForm.addedEval.evalTime;
                        addedCell.addedContentLabel.text = evalutionForm.addedEval.message;
                        float strHeight = [CZJUtils calculateStringSizeWithString:evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
                        addedCell.contentLabelHeight.constant = strHeight + 5;
                        
                        
                        for (int i = 0; i < evalutionForm.addedEval.evalImgs.count; i++)
                        {
                            NSString* url = evalutionForm.addedEval.evalImgs[i];
                            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(70, 70) index:i divide:Divide];
                            UIImageView* imageView = [[UIImageView alloc]initWithFrame:imageFrame];
                            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DefaultPlaceHolderImage];
                            [addedCell.picView addSubview:imageView];
                        }
                        float picViewHeight = 0;
                        if (evalutionForm.addedEval.evalImgs.count != 0)
                        {
                            picViewHeight = 70*(evalutionForm.addedEval.evalImgs.count / Divide + 1);
                        }
                        NSInteger addedHeight = 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
                        
                        CGRect addcellFrame = CGRectMake(0, cellHeight, PJ_SCREEN_WIDTH, addedHeight);
                        addedCell.frame = addcellFrame;
                        [cell addSubview:addedCell];
                    }
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            else
            {
                CZJEvalutionFooterCell* cell = (CZJEvalutionFooterCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell"];
                [cell setVisibleView:kLookAllEvalView];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
        case 6:
        {//门店信息介绍
            if (0 == indexPath.row)
            {
                CZJStoreInfoHeaerCell *cell = (CZJStoreInfoHeaerCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJStoreInfoHeaerCell"  forIndexPath:indexPath];
                if (_storeInfo)
                {
                    [cell.storeImage sd_setImageWithURL:[NSURL URLWithString:_storeInfo.logo]
                                            placeholderImage:DefaultPlaceHolderImage];
                    cell.storeName.text = _storeInfo.storeName;
                    cell.storeAddr.text = _storeInfo.storeAddr;
                    cell.storeAddrLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.storeNameLayoutWidth.constant = PJ_SCREEN_WIDTH - 200;
                    cell.attentionStore.selected = _storeInfo.attentionFlag;
                    if (_storeInfo.attentionFlag)
                    {
                        [cell.attentionStore setTitle:@"已关注" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [cell.attentionStore setTitle:@"关注门店" forState:UIControlStateNormal];
                    }
                    cell.delegate = self;
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
                [cell.intoStoreButton addTarget:self action:@selector(storeAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
            
        case 7:
        {//热门推荐
            CZJHotRecommendCell *cell = (CZJHotRecommendCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJHotRecommendCell" forIndexPath:indexPath];
            
            if (!cell.isInit && _recommendServiceForms.count > 0) {
                __weak typeof(self) weak = self;
                [cell setHotRecommendDatas:_recommendServiceForms andButtonHandler:^(id data) {
                    CZJStoreServiceForm* hotRecommendGood = (CZJStoreServiceForm*)data;
                    CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
                    detailVC.storeItemPid = hotRecommendGood.storeItemPid;
                    detailVC.promotionType = CZJGoodsPromotionTypeGeneral;
                    detailVC.promotionPrice = @"";
                    [weak.navigationController pushViewController:detailVC animated:YES];
                }];
            }
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        case 8:
        {//上拉查看图文详情
            CZJOrderTypeExpandCell *cell = (CZJOrderTypeExpandCell*)[tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeExpandCell" forIndexPath:indexPath];
            [cell setCellType:CZJCellTypeDetail];
            __weak typeof(self) weak = self;
            cell.buttonClick = ^(id data)
            {
                [weak.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-114)) animated:true];
                isButtom = NO;
            };
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
            
        default:
            return nil;
            break;
    }
    return nil;
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 375;
            break;
        case 1:
        {
            CZJDetailDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDetailDescCell"];
            NSString* itemName = _goodsDetail.itemName;
            CGSize prolabelSize = [CZJUtils calculateStringSizeWithString:itemName Font:cell.productNameLabel.font Width:PJ_SCREEN_WIDTH - 45];
            float itemNameHeight = prolabelSize.height < 15 ? 15 : prolabelSize.height;
            float miaoshaHeight = ((CZJGoodsPromotionTypeMiaoSha == _promotionType) ? 35 : 0);
            return 65 + itemNameHeight + miaoshaHeight + 5;
        }
            break;
        case 2:
            return 55;
            break;
        case 3:
            return 46;
            break;
        case 4:
            return 75;
            break;
        case 5:
            if (0 == indexPath.row) {
                return 46;
            }
            else if (_evalutionInfo.evalList.count + 1 > indexPath.row) {
                //这里是动态改变的，暂时设一个固定值
                CZJEvaluateForm* evalutionForm  = (CZJEvaluateForm*)_evalutionInfo.evalList[indexPath.row - 1];
                CGSize contenSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
                NSInteger row = evalutionForm.evalImgs.count / Divide + 1;
                NSInteger cellHeight = 60 + (contenSize.height > 20 ? contenSize.height : 20) + row * 88;
                
                NSInteger addedHeight = 0;
                if ([evalutionForm.added boolValue])
                {
                    float strHeight = [CZJUtils calculateStringSizeWithString:evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40].height;
                    float picViewHeight = 0;
                    if (evalutionForm.addedEval.evalImgs.count != 0)
                    {
                        picViewHeight = 70*(evalutionForm.addedEval.evalImgs.count / Divide + 1);
                    }
                    addedHeight = 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
                }
                return cellHeight + addedHeight;
                
            }
            else
            {
                return 64;
            }
            break;
        case 6:
            if (0 == indexPath.row)
            {
                return 81;
            }
            if (1 == indexPath.row)
            {
                return 131;
            }
            break;
        case 7:
            return (iPhone4 || iPhone5) ? 400 : 400;
            break;
            
        case 8:
            return 46;
            break;
            
        default:
            return 46;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section ||
        1 == section ||
        2 == section ||
        3 == section ||
        4 == section ||
        (5 == section && _evalutionInfo.evalList.count == 0))
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.section)
    {
        __weak typeof(self) weak = self;
        self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
        CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
        receiveCouponsController.storeId = _storeInfo.storeId;
        receiveCouponsController.popWindowInitialRect = self.popWindowInitialRect;
        [CZJUtils showMyWindowOnTarget:weak withMyVC:receiveCouponsController];
        
        
        [receiveCouponsController setCancleBarItemHandle:^{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weak.window.frame = self.popWindowInitialRect;
                weak.upView.alpha = 0.0;
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
        __weak typeof(self) weak = self;
        self.popWindowInitialRect =  CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        self.popWindowDestineRect = CGRectMake(50, 0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT);
        CZJChooseProductTypeController *chooseProductTypeController = [[CZJChooseProductTypeController alloc] init];
        chooseProductTypeController.goodsDetail = chooosedProductCell.goodsDetail;
        chooseProductTypeController.buycount = buyCount;
        [CZJUtils showMyWindowOnTarget:weak withMyVC:chooseProductTypeController];
        
        [chooseProductTypeController setCancleBarItemHandle:^{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weak.window.frame = self.popWindowInitialRect;
                weak.upView.alpha = 0.0;
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
    if (4 == indexPath.section)
    {
    }
    if (5 == indexPath.section)
    {
        [self performSegueWithIdentifier:@"segueToUserEvalution" sender:self];
    }
}


#pragma mark- CZJNaviBarViewDelegate(导航栏三个按钮的代理回调)
- (void)clickEventCallBack:(id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
        {
            NSArray * arr = @[
//                              @{@"消息" : @"prodetail_icon_msg"},
                              @{@"首页":@"prodetail_icon_home"},
                              @{@"分享" :@"prodetail_icon_share"}];
            if(dropDown == nil) {
                CGRect rect = CGRectMake(PJ_SCREEN_WIDTH - 120 - 14, StatusBar_HEIGHT + 78, 120, 100);
                _backgroundView.hidden = NO;
                dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr  andType:CZJNIDropDownTypeNormal];
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


#pragma mark- NIDropDownDelegate(更多按钮弹出框回调)
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"消息"])
    {
    }
    if ([btnStr isEqualToString:@"首页"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([btnStr isEqualToString:@"分享"])
    {
    }
}


#pragma mark- CZJStoreInfoHeaerCellDelegate(关注店铺回调)
- (void)clickAttentionStore:(id)sender
{
    NSDictionary* params = @{@"storeId" : _storeInfo.storeId};
    if (!_storeInfo.attentionFlag) {
        [CZJBaseDataInstance attentionStore:params success:^(id json) {
            _storeInfo.attentionFlag = !_storeInfo.attentionFlag;
            _storeInfo.attentionCount = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            [self.detailTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
            [CZJUtils tipWithText:@"关注门店成功" andView:self.view];
        }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionStore:params success:^(id json) {
            _storeInfo.attentionFlag = !_storeInfo.attentionFlag;
            _storeInfo.attentionCount = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            [self.detailTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
            [CZJUtils tipWithText:@"取消门店关注" andView:self.view];
        }];
    }
}


#pragma mark- ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
     DLog(@"contentOffsetY:%f, tableViewContentSizeHeight:%f",contentOffsetY, tableViewContentSizeHeight);
    if (kTagTableView == scrollView.tag && contentOffsetY <=0)
    {
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(0)];
    }
    else if (kTagTableView == scrollView.tag && contentOffsetY > 0)
    {
        float alphaValue = contentOffsetY / 300;
        if (alphaValue > 1)
        {
            alphaValue = 1;
        }
        [self.naviBarView.btnBack setBackgroundColor:RGBA(247, 247, 247,(1 - alphaValue))];
        [self.naviBarView.btnMore setBackgroundColor:RGBA(247, 247, 247,(1 - alphaValue))];
        [self.naviBarView.btnShop setBackgroundColor:RGBA(247, 247, 247,(1 - alphaValue))];
        [self.naviBarView setBackgroundColor:CZJNAVIBARBGCOLORALPHA(alphaValue)];
    }
    
    //去掉tableview中section的headerview粘性
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
    if (scrollView.tag ==kTagTableView && contentOffsetY > tableViewContentSizeHeight) {
        isButtom = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    float contentOffsetY = [scrollView contentOffset].y;

    if (isButtom && kTagTableView == scrollView.tag && contentOffsetY >= tableViewContentSizeHeight + 40)
    {
        [self.myScrollView setContentOffset:CGPointMake(0, (PJ_SCREEN_HEIGHT-114)) animated:true];
        isButtom = NO;
    }
    DLog(@"contentOffsetY:%f, velocity.y:%f, offset:%f",contentOffsetY,velocity.y, targetContentOffset->y);
}


#pragma mark- CZJImageTouchViewDelegate(顶部图片预览回调)
- (void)showDetailInfoWithIndex:(NSInteger)index
{
    WyzAlbumViewController *wyzAlbumVC = [[WyzAlbumViewController alloc]init];
    wyzAlbumVC.currentIndex =index;//这个参数表示当前图片的index，默认是0
    //用url
    wyzAlbumVC.imgArr = _goodsDetail.imgs;
    //进入动画
    [self presentViewController:wyzAlbumVC animated:YES completion:^
    {
    }];
}


#pragma mark- CZJChooseProductTypeDelegate(规格筛选弹出视图回调)

- (void)productTypeImeditelyBuyCallBack
{
    [self addProductToShoppingCartAction:nil];
}

- (void)productTypeAddtoShoppingCartCallBack
{
    [self immediatelyBuyAction:nil];
}

#pragma mark- Action
- (IBAction)immediatelyBuyAction:(id)sender
{
    [_settleOrderAry removeAllObjects];
    if ([USER_DEFAULT boolForKey:kCZJIsUserHaveLogined])
    {
        NSDictionary* itemDict = @{@"itemCode" : goodsDetailForm.goods.itemCode,
                                   @"storeItemPid" : goodsDetailForm.goods.storeItemPid,
                                   @"itemImg" : goodsDetailForm.goods.itemImg,
                                   @"itemName" : goodsDetailForm.goods.itemName,
                                   @"itemSku" : goodsDetailForm.goods.itemSku,
                                   @"itemType" : goodsDetailForm.goods.itemType,
                                   @"itemCount" : @"1",
                                   @"currentPrice" : goodsDetailForm.goods.currentPrice
                                   };
        
        NSArray* itemAry = @[itemDict];
        NSDictionary* storeDict = @{@"items" :itemAry,
                                    @"storeName" : goodsDetailForm.store.storeName,
                                    @"storeId" :goodsDetailForm.store.storeId,
                                    @"companyId" :goodsDetailForm.store.companyId,
                                    @"selfFlag" : goodsDetailForm.goods.selfFlag ? @"true" : @"false"
                                    };
        [_settleOrderAry addObject:storeDict];
        
        [CZJUtils showCommitOrderView:self andParams:_settleOrderAry];
    }
    else
    {
        [CZJUtils showLoginView:self andNaviBar:self.naviBarView];
    }

}

- (IBAction)addProductToShoppingCartAction:(id)sender
{
    NSDictionary* pramas = @{
                             @"companyId" : _goodsDetail.companyId ? _goodsDetail.companyId : @"",
                             @"storeId" : _goodsDetail.storeId,
                             @"storeItemPid" : _goodsDetail.storeItemPid,
                             @"itemType" : _goodsDetail.itemType,
                             @"itemCode" : _goodsDetail.itemCode,
                             @"itemName" : _goodsDetail.itemName,
                             @"itemCount" : @1,
                             @"currentPrice" : _goodsDetail.currentPrice,
                             @"itemImg" : _goodsDetail.itemImg,
                             @"itemSku" : _goodsDetail.itemSku,
                             @"counterKey" : _goodsDetail.counterKey
                             };
    
    [CZJBaseDataInstance addProductToShoppingCart:pramas Success:^{
        CGRect addBtnRect = [self.view convertRect:_addProductToShoppingCartBtn.frame fromView:_shoppingCartView];
        CGRect shoppingCartBtnRect = [self.view convertRect:self.naviBarView.btnShop.frame fromView:self.naviBarView];
        
        UIImageView* itemImage = [[UIImageView alloc] initWithImage:IMAGENAMED(@"prodetail_btn_shop")];
        itemImage.frame = CGRectMake(addBtnRect.origin.x + (addBtnRect.size.width - 50)/2, addBtnRect.origin.y + (addBtnRect.size.height - 40)/2, 40, 40);
        [self.view addSubview:itemImage];
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            itemImage.size  = CGSizeMake(20, 20);
            CGPoint desPt = CGPointMake(shoppingCartBtnRect.origin.x + shoppingCartBtnRect.size.width*0.5,shoppingCartBtnRect.origin.y + shoppingCartBtnRect.size.height*0.5);
            [itemImage setPosition:desPt atAnchorPoint:CGPointMake(0.5, 0.5)];
            itemImage.alpha = 0.8;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    itemImage.alpha = 0;
                    itemImage.transform = CGAffineTransformMakeScale(3, 3);
                } completion:^(BOOL finished) {
                    [itemImage removeFromSuperview];
                }];
                [self.naviBarView refreshShopBadgeLabel];
            }
        }];
        
    } fail:^{
        
    }];
}


- (IBAction)attentionAction:(id)sender
{
    NSDictionary* params = @{@"storeItemPid" : _goodsDetail.storeItemPid,
                             @"itemType" : _goodsDetail.itemType};
    if (!self.attentionBtn.selected)
    {
        [CZJBaseDataInstance attentionGoods:params success:^(id json)
        {
            _goodsDetail.attentionFlag = !_goodsDetail.attentionFlag;
            self.attentionBtn.selected = !self.attentionBtn.selected;
            [CZJUtils tipWithText:@"关注商品成功" andView:self.view];
        }];
    }
    else
    {
        [CZJBaseDataInstance cancleAttentionGoods:params success:^(id json)
        {
            _goodsDetail.attentionFlag = !_goodsDetail.attentionFlag;
            self.attentionBtn.selected = !self.attentionBtn.selected;
            [CZJUtils tipWithText:@"取消商品关注" andView:self.view];
        }];
    }
}

- (IBAction)contactServiceAction:(id)sender
{
    
}

- (IBAction)storeAction:(id)sender
{
    CZJStoreDetailController* storeDetailVC = (CZJStoreDetailController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"storeDetailVC"];
    storeDetailVC.storeId = _storeInfo.storeId;
    [self.navigationController pushViewController:storeDetailVC animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToUserEvalution"])
    {
        CZJUserEvalutionController* userEvalutionVC = segue.destinationViewController;
        userEvalutionVC.counterKey = goodsDetailForm.goods.counterKey;
    }
}

- (void)tapPromotionCell:(id)sender
{
    DLog(@"%ld",((UIButton*)sender).tag);
    
    CZJPromotionController* promotionVC = (CZJPromotionController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"promotionSBID"];
    promotionVC.type = [NSString stringWithFormat:@"%ld",((UIButton*)sender).tag];
    promotionVC.storeId = goodsDetailForm.goods.storeId;
    [self.navigationController pushViewController:promotionVC animated:YES];
}


#pragma mark- 秒杀
- (void)setTimestamp:(NSInteger)timestamp{
    _timestamp = timestamp;
    if (_timestamp != 0) {
        [self refreshTimeStamp];
        if (!timer) {
            timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimeStamp) userInfo:nil repeats:YES];
        }
    }
}

- (void)refreshTimeStamp
{
    _timestamp--;
    CZJDateTime* mydateTime = [CZJUtils getLeftDatetime:_timestamp];
    miaoShaCell.hourLabel.text = mydateTime.hour;
    miaoShaCell.minutesLabel.text = mydateTime.minute;
    miaoShaCell.secondLabel.text = mydateTime.second;
    
    if (_timestamp == 0) {
        [timer invalidate];
        timer = nil;
        // 执行block回调
        _promotionType = CZJGoodsPromotionTypeGeneral;
        [self getDataFromServer];
    }
}

@end
