//
//  CZJChooseProductTypeController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJChooseProductTypeController.h"
#import "CZJBaseDataManager.h"
#import "CZJChooseTypeHeaderCell.h"
#import "CZJSerFilterTypeChooseCell.h"
#import "WLZ_ChangeCountView.h"


@interface CZJChooseProductTypeController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    __block CZJChooseTypeHeaderCell* typeHeadercell;
    NSMutableArray* _items;
    NSMutableArray* _labels;
    NSMutableArray* _oneLevelSkus;
    NSMutableArray* _twoLevelSkus;
    NSMutableArray* _choosedSkuValues;
    NSInteger _choosedId;
    NSInteger _currentIndex;
    
    NSString* oneLevelChoosed;
    NSString* twoLevelChoosed;
    NSString* _twoLevelChoosedValueID;
    NSString* _skuValueID;
    
    NSInteger choosedCount;
    UITableViewCell* addCellView;
    
    BOOL isFirstLoad;
    BOOL isFirstLoadTwo;
}
@property(nonatomic, strong)UITableView* tableView;
@end

@implementation CZJChooseProductTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initMyViews];
    [self getSKUDataFromServer];
}

- (void)initMyDatas
{
    _items = [NSMutableArray array];
    _labels = [NSMutableArray array];
    _oneLevelSkus = [NSMutableArray array];
    _twoLevelSkus = [NSMutableArray array];
    _choosedSkuValues = [NSMutableArray array];
    _choosedSkuValues = [[self.goodsDetail.sku.skuValueIds componentsSeparatedByString:@","] mutableCopy];
    _twoLevelChoosedValueID = _choosedSkuValues.count == 2 ? _choosedSkuValues[1] : nil;
    _currentIndex = 1;
    choosedCount = _buycount;
    isFirstLoad = YES;
    isFirstLoadTwo = YES;
}

- (void)initMyViews
{
    
    //弹出框顶部标题栏
    typeHeadercell = [CZJUtils getXibViewByName:@"CZJChooseTypeHeaderCell"];
    typeHeadercell.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, 80);
    [self.view addSubview:typeHeadercell];
    
    //右上角叉叉退出按钮
    UIButton* _exitBt = [[UIButton alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 44, 5, 44, 44)];
    [_exitBt addTarget:self action:@selector(exitTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_exitBt setImage:IMAGENAMED(@"prodetail_icon_off") forState:UIControlStateNormal];
    [typeHeadercell addSubview:_exitBt];
    

    //添加TableView
    [self.view addSubview:self.tableView];
    UINib* nib = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
    
    
    //TableView
     CGRect rect = self.popWindowInitialRect;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 80, PJ_SCREEN_WIDTH, rect.size.height - 50 - 80) style:UITableViewStylePlain];
    _tableView.userInteractionEnabled=YES;
    _tableView.scrollsToTop=YES;
    _tableView.scrollEnabled = YES;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_tableView];
    UINib* nib1 = [UINib nibWithNibName:@"CZJChooseTypeHeaderCell" bundle:nil];
    [_tableView registerNib:nib1 forCellReuseIdentifier:@"CZJChooseTypeHeaderCell"];
    
    //底部加入购物车或立即购买
    UIButton* addToShoppingCartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addToShoppingCartBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [addToShoppingCartBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [addToShoppingCartBtn setBackgroundColor:CZJGREENCOLOR];
    [addToShoppingCartBtn.titleLabel setFont:SYSTEMFONT(15)];
    [addToShoppingCartBtn addTarget:self action:@selector(addToShppingCartAction) forControlEvents:UIControlEventTouchUpInside];
    UIButton* immeditelyBuyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [immeditelyBuyBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [immeditelyBuyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    [immeditelyBuyBtn setBackgroundColor:CZJREDCOLOR];
    [immeditelyBuyBtn.titleLabel setFont:SYSTEMFONT(15)];
    [immeditelyBuyBtn addTarget:self action:@selector(imeditelyBuyAction) forControlEvents:UIControlEventTouchUpInside];
    
    if (0 == [_goodsDetail.buyType floatValue])
    {
        CGRect addRect = CGRectMake(0, PJ_SCREEN_HEIGHT - 250, PJ_SCREEN_WIDTH*0.5, 50);
        CGRect imditelyRect = CGRectMake(PJ_SCREEN_WIDTH*0.5, PJ_SCREEN_HEIGHT - 250, (PJ_SCREEN_WIDTH)*0.5, 50);
        addToShoppingCartBtn.frame = addRect;
        immeditelyBuyBtn.frame = imditelyRect;
        [self.view addSubview:addToShoppingCartBtn];
        [self.view addSubview:immeditelyBuyBtn];
    }
    if (1 == [_goodsDetail.buyType floatValue])
    {
        addToShoppingCartBtn.hidden = YES;
        CGRect imditelyRect = CGRectMake(0, PJ_SCREEN_HEIGHT - 250, (PJ_SCREEN_WIDTH - 50), 50);
        immeditelyBuyBtn.frame = imditelyRect;
        [self.view addSubview:immeditelyBuyBtn];
    }
}

- (void)imeditelyBuyAction
{
    if ([self.delegate respondsToSelector:@selector(productTypeImeditelyBuyCallBack)])
    {
        [self.delegate productTypeImeditelyBuyCallBack];
        [self exitTouch:nil];
    }
}

- (void)addToShppingCartAction
{
    if ([self.delegate respondsToSelector:@selector(productTypeAddtoShoppingCartCallBack)])
    {
        [self.delegate productTypeAddtoShoppingCartCallBack];
        [self exitTouch:nil];
    }
}

- (void)exitTouch:(id)sender
{
    if(self.basicBlock)self.basicBlock();
}

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock
{
    self.basicBlock = basicBlock;
}

- (void)getSKUDataFromServer
{
    
    NSDictionary* params = @{@"storeItemPid" : self.goodsDetail.storeItemPid == nil ? @"" : self.goodsDetail.storeItemPid,
                             @"counterKey" : self.goodsDetail.counterKey == nil ? @"" : self.goodsDetail.counterKey};
    
    __weak typeof(self) weakSelf = self;
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        DLog(@"%@",[dict description]);
        NSArray* tmpItems = [[dict valueForKey:@"msg"] valueForKey:@"items"];
        _items = [[CZJGoodsSKU objectArrayWithKeyValuesArray:tmpItems] mutableCopy];
        _labels = [[dict valueForKey:@"msg"] valueForKey:@"labels"];
        NSArray* skus = [[dict valueForKey:@"msg"] valueForKey:@"skus"];
        _oneLevelSkus = [[CZJLevelSku objectArrayWithKeyValuesArray:skus] mutableCopy];
        _tableView.delegate = weakSelf;
        _tableView.dataSource = weakSelf;
        [_tableView reloadData];
        
        [weakSelf refreshChoooseTypeHeader];
    };
    
    [CZJBaseDataInstance loadGoodsSKU:params
                              Success:successBlock
                                 fail:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _labels.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_labels.count == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else
        {
            return 50;
        }
    }
    else
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else
        {
            int col;
            if (1 == _labels.count || indexPath.section == 0)
            {
                col = ceilf(_oneLevelSkus.count / 3.0);
            }
            else if (indexPath.section == 1 && 2 == _labels.count)
            {
                for (CZJLevelSku* skuForm in _oneLevelSkus)
                {
                    _twoLevelSkus = skuForm.twoSkus;
                    continue;
                }
                col = ceilf(_twoLevelSkus.count / 3.0);
            }
            return  col * 55;
        }
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"section:%ld, row:%ld",indexPath.section,indexPath.row);
    if (_labels.count == indexPath.section)
    {//数量
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.textLabel.text = @"数量";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (1 == indexPath.row)
        {
            addCellView = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            WLZ_ChangeCountView* _changeView = [[WLZ_ChangeCountView alloc] initWithFrame:CGRectMake(20, 8 , 120, 35) chooseCount:_buycount totalCount: 99];
            [_changeView.subButton addTarget:self action:@selector(subButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_changeView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_changeView setTag:1010];
            [addCellView.contentView addSubview:_changeView];
            addCellView.selectionStyle = UITableViewCellSelectionStyleNone;
            return addCellView;
        }
    }
    else
    {
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3"];
            cell.textLabel.text = _labels[indexPath.section];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSInteger totalIndex = _labels.count;
            NSInteger level = indexPath.section;
            if (0 == level && level < totalIndex)
            {//一级SKU
                oneLevelChoosed = _choosedSkuValues[level];  //比如：容量
                for (CZJLevelSku*goodSku in _oneLevelSkus)
                {
                    if ([goodSku.valueId isEqualToString:oneLevelChoosed] && isFirstLoad)
                    {
                        isFirstLoad = NO;
                        _skuValueID = goodSku.valueId;
                        continue;
                    }
                }
                [cell setButtonDatas:_oneLevelSkus WithType:kCZJSerfilterTypeChooseCellTypeDetail];
                [cell setDefaultSelectBtn:oneLevelChoosed];
                
                __weak typeof(self) weakSelf = self;
                [cell setButtonBlock:^(UIButton* button)
                 {
                     DLog(@"%ld,%@",button.tag, button.titleLabel.text);
                     for (CZJLevelSku*goodSku in _oneLevelSkus)
                     {
                         if ([goodSku.valueId integerValue] == button.tag)
                         {
                             if (1 == _labels.count)
                             {
                                 for (CZJGoodsSKU* skuForm in _items)
                                 {
                                     if ([skuForm.skuValueIds integerValue] ==  button.tag)
                                     {
                                         weakSelf.goodsDetail.sku = skuForm;
                                         continue;
                                     }
                                 }
                                 [weakSelf refreshChoooseTypeHeader];
                                 [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshDetailView object:nil userInfo:@{@"storeItemPid" : weakSelf.goodsDetail.sku.storeItemPid,@"buycount" : @(choosedCount)}];
                             }
                             else
                             {
                                 _skuValueID = [NSString stringWithFormat:@"%ld",button.tag];
                                 oneLevelChoosed = _skuValueID;
                                 NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
                                 [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                                 NSString* valueIds = [NSString stringWithFormat:@"%@,%@",_skuValueID,_twoLevelChoosedValueID];
                                 DLog(@"reload over:%@",valueIds);
                                 [weakSelf getChoosedStoreItemPid:valueIds];
                             }
                         }
                     }
                     
                 }];
                return cell;
            }
            else if (1 == level && level < totalIndex)
            {
                for (CZJLevelSku* skuForm in _oneLevelSkus)
                {
                    if ([oneLevelChoosed isEqualToString:skuForm.valueId])
                    {
                        _twoLevelSkus = skuForm.twoSkus;
                        [cell setButtonDatas:_twoLevelSkus WithType:kCZJSerfilterTypeChooseCellTypeDetail];
                        if (isFirstLoadTwo)
                        {
                            isFirstLoadTwo = NO;
                            twoLevelChoosed = _choosedSkuValues[level];   //比如：粘稠度
                        }
                        else
                        {
                            CZJLevelSku* skuForms = (CZJLevelSku*)[_twoLevelSkus firstObject];
                            twoLevelChoosed = skuForms.valueId;
                            _twoLevelChoosedValueID = skuForms.valueId;
                        }
                        [cell setDefaultSelectBtn:twoLevelChoosed];
                        [cell setButtonBlock:^(UIButton* button)
                         {
                             DLog(@"%ld,%@",button.tag, button.titleLabel.text);
                             _twoLevelChoosedValueID = [NSString stringWithFormat:@"%ld",button.tag] ;
                             NSString* valueIds = [NSString stringWithFormat:@"%@,%@",_skuValueID,_twoLevelChoosedValueID];
                             DLog(@"reload over:%@",valueIds);
                             [self getChoosedStoreItemPid:valueIds];
                         }];
                        continue;
                    }
                }
                return cell;
            }
        }
    }
    return nil;
}


#pragma mark- Actions
- (void)subButtonPressed:(id)sender
{
    --choosedCount ;
    if (choosedCount <= 1) {
        choosedCount= 1;
        ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).subButton.enabled=NO;
    }
    else
    {
        ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).addButton.enabled=YES;
        
    }
    ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).numberFD.text=[NSString stringWithFormat:@"%zi",choosedCount];
    [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshDetailView object:nil userInfo:@{@"storeItemPid" : self.goodsDetail.sku.storeItemPid,@"buycount" : @(choosedCount)}];
}

- (void)addButtonPressed:(id)sender
{
    ++choosedCount ;
    if (choosedCount > 1) {
        ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).subButton.enabled=YES;
    }
    
    if(choosedCount>=99)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"最多支持购买99个";
        choosedCount  = 99;
        ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).addButton.enabled = NO;
    }
    
    ((WLZ_ChangeCountView*)VIEWWITHTAG(addCellView, 1010)).numberFD.text=[NSString stringWithFormat:@"%zi",choosedCount];
    [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshDetailView object:nil userInfo:@{@"storeItemPid" : self.goodsDetail.sku.storeItemPid,@"buycount" : @(choosedCount)}];
}

- (void)getChoosedStoreItemPid:(NSString*)valueIDs
{
    for (CZJGoodsSKU* skuForm in _items)
    {
        if ([skuForm.skuValueIds isEqualToString:valueIDs])
        {
            self.goodsDetail.sku.storeItemPid = skuForm.storeItemPid;
            self.goodsDetail.sku = skuForm;
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshDetailView object:nil userInfo:@{@"storeItemPid" : self.goodsDetail.sku.storeItemPid,@"buycount" : @(choosedCount)}];
            
            //弹出框顶部标题栏
            [self refreshChoooseTypeHeader];
            
            continue;
        }
    }
}


- (void)refreshChoooseTypeHeader
{
    typeHeadercell.productNameLabel.text = @"";
    typeHeadercell.productPriceLabel.text = [NSString stringWithFormat:@"￥%@",self.goodsDetail.sku.skuPrice];
    typeHeadercell.productCodeLabel.text = self.goodsDetail.sku.skuCode;
    [typeHeadercell.productImage sd_setImageWithURL:[NSURL URLWithString:self.goodsDetail.sku.skuImg] placeholderImage:DefaultPlaceHolderSquare];
}

@end
