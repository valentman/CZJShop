//
//  CZJShoppingCartController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJShoppingCartController.h"
#import "CZJBaseDataManager.h"
#import "CZJShoppingCartForm.h"
#import "CZJShoppingCartCell.h"
#import "CZJShoppingCartHeaderCell.h"
#import "CZJReceiveCouponsController.h"
#import "CZJCommitOrderController.h"
#import "CZJStoreDetailController.h"
#import "CZJDetailViewController.h"

@interface CZJShoppingCartController ()
<
CZJShoppingCartCellDelegate,
CZJShoppingCartHeaderCellDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate
>
{
    NSMutableArray* shoppingInfos;
    NSInteger _selectedCount;
    NSMutableArray* _settleOrderAry;
    UIButton* editBtn;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *settleBtn;
@property (weak, nonatomic) IBOutlet UIButton *allChooseBtn;
@property (weak, nonatomic) IBOutlet UILabel *allChooseLabel;
@property (weak, nonatomic) IBOutlet UILabel *addUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *addUpNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settleBtnWidth;
@property (weak, nonatomic) IBOutlet UIView *settleView;


- (IBAction)settleActioin:(id)sender;
- (IBAction)allChooseAction:(id)sender;

@property(nonatomic,assign)BOOL isEdit;
@end

@implementation CZJShoppingCartController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getShoppingCartInfoFromServer];
}

- (void)viewWillLayoutSubviews
{
    _settleView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 50, PJ_SCREEN_WIDTH, 50);
}

- (void)viewDidLayoutSubviews
{
    _settleView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 50, PJ_SCREEN_WIDTH, 50);
}

- (void)initDatas
{
    shoppingInfos = [NSMutableArray array];
    _selectedCount = 0;
    if (iPhone5 || iPhone4)
    {
        _settleBtnWidth.constant = 100;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getShoppingCartInfoFromServer) name:@"commitOrderSuccess" object:nil];
}

- (void)initViews
{
    self.view.backgroundColor = CZJNAVIBARGRAYBG;
    //tableview
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.backgroundColor = CZJNAVIBARGRAYBG;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UINib* nib1 = [UINib nibWithNibName:@"CZJShoppingCartCell" bundle:nil];
    UINib* nib2 = [UINib nibWithNibName:@"CZJShoppingCartHeaderCell" bundle:nil];
    [self.myTableView registerNib:nib1 forCellReuseIdentifier:@"CZJShoppingCartCell"];
    [self.myTableView registerNib:nib2 forCellReuseIdentifier:@"CZJShoppingCartHeaderCell"];
    self.myTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^(){
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
        } completion:^(BOOL finished) {
            //结束加载
            [self.myTableView.header endRefreshing];
        }];
    }];
    
    //右按钮
    editBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(PJ_SCREEN_WIDTH - 59 , 0 , 44 , 44 )];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitle:@"完成" forState:UIControlStateSelected];
    [editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [editBtn setSelected:NO];
    editBtn.hidden = YES;
    editBtn.titleLabel.font = SYSTEMFONT(18);
    
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle.png") forState:UIControlStateNormal];
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle_sel.png") forState:UIControlStateSelected];
    _allChooseBtn.selected = NO;
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    [self.naviBarView addSubview:editBtn];
    self.naviBarView.mainTitleLabel.text = @"我的购物车";
    [self.naviBarView.btnBack addTarget:self action:@selector(backToLastView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.settleView.hidden = NO;
}


- (void)getShoppingCartInfoFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.myTableView animated:YES];
    self.settleView.hidden = YES;
    CZJSuccessBlock successBlock = ^(id json)
    {
        [MBProgressHUD hideAllHUDsForView:self.myTableView animated:NO];
        [shoppingInfos removeAllObjects];
        shoppingInfos = [[CZJBaseDataInstance shoppingCartForm] shoppingCartList];
        if (shoppingInfos.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有商品，快去添加吧/(ToT)/~~"];
            self.settleView.hidden = YES;
        }
        else
        {
            DLog(@"settleView.y:%f",_settleView.frame.origin.y);
            self.settleView.hidden = NO;
            editBtn.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self calculateTotalPrice];
        }
    };
    CZJFailureBlock failBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self.myTableView animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getShoppingCartInfoFromServer];
        }];
    };
    [CZJBaseDataInstance loadShoppingCart:nil
                                     type:CZJHomeGetDataFromServerTypeOne
                                  Success:successBlock
                                     fail:failBlock];
}

//计算总价
- (void)calculateTotalPrice
{
    float num = 0.00;
    BOOL allChoose = YES;
    for (int i=0; i<shoppingInfos.count; i++) {
        CZJShoppingCartInfoForm* storeCartForm = (CZJShoppingCartInfoForm*)shoppingInfos[i];
        storeCartForm.isSelect = NO;
        NSArray* goodsInfos = storeCartForm.items;
        for (int j = 0; j<goodsInfos.count; j++) {
            CZJShoppingGoodsInfoForm *model = goodsInfos[j];
            NSInteger count = [model.itemCount integerValue];
            float sale = [model.currentPrice floatValue];
            if (model.isSelect && !model.off)
            {
                storeCartForm.isSelect = YES;
                num = count*sale+ num;
            }
            else if (!model.isSelect)
            {
                allChoose = NO;
            }
        }
    }
    _allChooseBtn.selected = allChoose;
    self.addUpNumLabel.text = [NSString stringWithFormat:@"￥%.2f",num];
    [self calculateSelectdCount];
}

- (void)calculateSelectdCount
{
    _selectedCount = 0;
    for (int i =0; i<shoppingInfos.count; i++)
    {
        NSArray* goodsList = ((CZJShoppingCartInfoForm*)shoppingInfos[i]).items;
        for (int j=0; j<goodsList.count; j++)
        {
            CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)goodsList[j];
            if (model.isSelect && !model.off)
            {
                _selectedCount++;
            }
        }
    }
    if (self.isEdit)
    {
        self.addUpLabel.hidden = YES;
        self.addUpNumLabel.hidden = YES;
        [self.settleBtn setTitle:[NSString stringWithFormat:@"删除(%ld)",_selectedCount] forState:UIControlStateNormal];
    }
    else
    {
        self.addUpLabel.hidden = NO;
        self.addUpNumLabel.hidden = NO;
        [self.settleBtn setTitle:[NSString stringWithFormat:@"去结算(%ld)",_selectedCount] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- ClickEventCallback
- (void)backToLastView:(id)sender
{
    [((CZJNaviagtionBarView*)self.delegate) refreshShopBadgeLabel];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"commitOrderSuccess" object:nil];
//    [self.navigationController popViewControllerAnimated:true];
}


- (void)edit:(id)sender
{
    UIButton* itemButton = (UIButton*)sender;
    itemButton.selected = !itemButton.selected;
    self.isEdit = !self.isEdit;
    [self calculateSelectdCount];
    for (int i=0; i<shoppingInfos.count; i++)
    {
        NSArray *goodsList = ((CZJShoppingCartInfoForm*)shoppingInfos[i]).items;
        for (int j = 0; j<goodsList.count-1; j++)
        {
            CZJShoppingGoodsInfoForm *model = goodsList[j];
            if (model.off) {
                model.isSelect=!self.isEdit;
            }
            else
            {
                model.isSelect=self.isEdit ? YES : NO;
            }
        }
    }
    [self pitchOn];
    [self.myTableView reloadData];
}


- (void)pitchOn
{//主要作用是更新门店header的。
    self.allChooseBtn.selected = YES;
    
    for (int i =0; i<shoppingInfos.count; i++)
    {
        CZJShoppingCartInfoForm* form = shoppingInfos[i];
        form.isSelect = YES;
        int offCount = 0;
        for (int j=0; j<form.items.count; j++)
        {
            CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)form.items[j];
            if (model.off)
            {
                offCount++;
            }
            else
            {
                if (!model.isSelect)
                {
                    form.isSelect = NO;
                    self.allChooseBtn.selected = NO;
                }
            }
        }
        if (offCount == form.items.count)
        {
            form.isSelect = NO;
            self.allChooseBtn.selected = NO;
        }
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DLog(@"购物车信息条数:%ld",shoppingInfos.count);
    return shoppingInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DLog(@"%ld", ((CZJShoppingCartInfoForm*)shoppingInfos[section]).items.count);
    return ((CZJShoppingCartInfoForm*)shoppingInfos[section]).items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJShoppingCartInfoForm* _shoppingcartInfo = (CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section];
    if (0 == indexPath.row) {
        CZJShoppingCartHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJShoppingCartHeaderCell" forIndexPath:indexPath];
        if (shoppingInfos.count > 0)
        {
            cell.indexPath = indexPath;
            cell.delegate = self;
            [cell setModels:_shoppingcartInfo];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        CZJShoppingGoodsInfoForm* goodsInfo = (CZJShoppingGoodsInfoForm*)_shoppingcartInfo.items[indexPath.row -1];
        CZJShoppingCartCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJShoppingCartCell" forIndexPath:indexPath];
        if (goodsInfo)
        {
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.isEdit = self.isEdit;
            [cell setModels:goodsInfo];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    return nil;
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (0 == indexPath.row)
    {
        return 44;
    }
    else
    {
        return 129;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CZJShoppingCartInfoForm* _shoppingcartInfo = (CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section];
//    if (0 == indexPath.row)
//    {//跳转到门店详情
//        [CZJUtils showStoreDetailView:self.navigationController andStoreId:_shoppingcartInfo.storeId];
//    }
//    else
//    {//跳转到商品详情
//        CZJShoppingGoodsInfoForm* goodsInfo = (CZJShoppingGoodsInfoForm*)_shoppingcartInfo.items[indexPath.row -1];
//        [CZJUtils showGoodsServiceDetailView:self.navigationController andItemPid:goodsInfo.storeItemPid detailType:[goodsInfo.itemType integerValue]];
//    }
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CZJShoppingCartInfoForm *goodsList = [shoppingInfos objectAtIndex:indexPath.section];
        CZJShoppingGoodsInfoForm *model = [ goodsList.items objectAtIndex:indexPath.row -1];
        NSDictionary* params = @{@"storeItemPids" : model.storeItemPid};
        [CZJBaseDataInstance removeProductFromShoppingCart:params Success:^{
            [CZJBaseDataInstance loadShoppingCartCount:nil Success:^(id json){
                NSDictionary* dict = [CZJUtils DataFromJson:json];
                [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            } fail:nil];
            model.isSelect=NO;
            [goodsList.items removeObjectAtIndex:indexPath.row - 1];
            
            if (0 == goodsList.items.count ){
                [shoppingInfos removeObjectAtIndex:indexPath.section];
                if (shoppingInfos.count == 0)
                {
                    [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有商品，快去添加吧/(ToT)/~~"];
                    self.settleView.hidden = YES;
                    editBtn.hidden = YES;
                    [self.myTableView reloadData];
                }
            }
            else
            {
                [self.myTableView reloadData];
            }

        } fail:^{
            //删除失败
        }];
    }
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark- PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
}


#pragma mark- CZJShoppingCartCellDelegate
- (void)singleClick:(CZJShoppingGoodsInfoForm *)models indexPath:(NSIndexPath *)indexPath
{
    [self pitchOn];
    NSLog(@"modelstype:%ld",indexPath.section);
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:indexPath.section];
    [self.myTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (void)changePurchaseNumberNotification
{
    [self calculateTotalPrice];
}


#pragma mark- CZJShoppingCartHeaderCellDelegate
- (void)clickChooseAllSection:(id)sender andIndexPath:(NSIndexPath *)indexPath
{
    
    DLog(@"section:%ld",indexPath.section);
    UIButton* cellAllChooseBtn = (UIButton*)sender;
    CZJShoppingCartInfoForm* form = (CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section];
    NSArray* goodsList = form.items;
    BOOL allGoodsChoosed = NO;
    for (int i =0; i<goodsList.count; i++)
    {
        CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)goodsList[i];
        if (model.off)
        {
            continue;
        }
        else
        {
            model.isSelect= !cellAllChooseBtn.selected;
            allGoodsChoosed = YES;
        }
    }

    if (allGoodsChoosed)
    {
        cellAllChooseBtn.selected = !cellAllChooseBtn.selected;
        form.isSelect = cellAllChooseBtn.selected;
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [self calculateTotalPrice];
        [self pitchOn];
    }
    else
    {
        [CZJUtils tipWithText:@"所选门店产品均无货" andView:nil];
    }
}

- (void)clickGetCoupon:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    self.popWindowDestineRect = CGRectMake(0, 200, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
    self.popWindowInitialRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
    CZJReceiveCouponsController *receiveCouponsController = [[CZJReceiveCouponsController alloc] init];
    receiveCouponsController.storeId = ((CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section]).storeId;
    [CZJUtils showMyWindowOnTarget:self withMyVC:receiveCouponsController];
    
    __weak typeof(self) weak = self;
    [receiveCouponsController setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weak.window.frame = weak.popWindowInitialRect;
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


#pragma mark- 结算按钮
- (IBAction)settleActioin:(id)sender
{
    if (self.isEdit)
    {
        //先遍历购物车数组中被选中的商品，将商品ID加入一个数组中。
        NSMutableArray* deleteAry = [NSMutableArray array];
        for (int i = 0; i<shoppingInfos.count; i++)
        {
            CZJShoppingCartInfoForm* form = shoppingInfos[i];
            NSMutableArray* goodsList = form.items;
            for (int j=0 ; j<goodsList.count; j++) {
                CZJShoppingGoodsInfoForm *model = goodsList[j];
                if (model.isSelect==YES) {
                    [deleteAry addObject:model.storeItemPid];
                    continue;
                }
            }
        }
        
        //再将待删除的商品id数组组合成一个字符串，作为删除参数
        NSString* storeItemPids = [deleteAry componentsJoinedByString:@","];
        NSDictionary* params = @{@"storeItemPids" : storeItemPids};
        [CZJBaseDataInstance removeProductFromShoppingCart:params Success:^{
            [CZJBaseDataInstance loadShoppingCartCount:nil Success:^(id json){
                NSDictionary* dict = [CZJUtils DataFromJson:json];
                [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            } fail:nil];
            
            //删除所选商品成功返回后，从本地商品数组中移除已删除的商品
            for (NSString* deleteStr in deleteAry)
            {
                for (int i = 0; i<shoppingInfos.count; i++)
                {
                    NSMutableArray* goodsList = ((CZJShoppingCartInfoForm*)shoppingInfos[i]).items;
                    for (int j=0 ; j<goodsList.count; j++)
                    {
                        CZJShoppingGoodsInfoForm *model = goodsList[j];
                        DLog(@"%@, %@", deleteStr, model.storeItemPid);
                        if ([deleteStr isEqualToString:model.storeItemPid])
                        {
                            [goodsList removeObjectAtIndex:j];
                            j = 0;
                            if (0 == goodsList.count )
                            {
                                [shoppingInfos removeObjectAtIndex:i];
                                i = 0;
                            }
                        }
                    }
                }
            }
            [self.myTableView reloadData];
        } fail:^{
            //删除失败
        }];
    }
    else
    {
        _settleOrderAry = [NSMutableArray array];
        for (int i = 0; i<shoppingInfos.count; i++)
        {
            BOOL isStoreSelected = NO;
            NSMutableArray* itemsAry = [NSMutableArray array];
            CZJShoppingCartInfoForm* form = shoppingInfos[i];
            NSMutableArray* goodsList = form.items;
            for (int j=0 ; j<goodsList.count; j++) {
                CZJShoppingGoodsInfoForm *model = goodsList[j];
                if (model.isSelect==YES && model.off != YES)
                {
                    isStoreSelected = YES;
                    NSDictionary* itemDict = @{@"itemCode" : model.itemCode,
                                               @"storeItemPid" : model.storeItemPid,
                                               @"itemImg" : model.itemImg,
                                               @"itemName" : model.itemName,
                                               @"itemSku" : model.itemSku,
                                               @"itemType" : model.itemType,
                                               @"itemCount" : model.itemCount,
                                               };
                    [itemsAry addObject:itemDict];
                }
            }
            if (isStoreSelected) {
                NSDictionary* storeDict = @{@"items" :itemsAry,
                                            @"storeName" : form.storeName,
                                            @"storeId" :form.storeId,
                                            @"companyId" :form.companyId,
                                            @"selfFlag" : form.selfFlag ? @"true" : @"false"
                                            };
                [_settleOrderAry addObject:storeDict];
            }
            
        }
        if (_settleOrderAry.count > 0)
        {
            [CZJUtils showCommitOrderView:self andParams:_settleOrderAry];
        }
        else
        {
            [CZJUtils tipWithText:@"您还没选择商品哦" andView:nil];
        }
    }
}

- (IBAction)allChooseAction:(id)sender
{
    BOOL allGoodsOff = YES;
    for (int i =0; i<shoppingInfos.count; i++) {
        CZJShoppingCartInfoForm* form = shoppingInfos[i];
        int offCount = 0;
        NSArray *goodsList = form.items;
        for (int j = 0; j<goodsList.count; j++)
        {
            CZJShoppingGoodsInfoForm *model = goodsList[j];
            if (model.off)
            {
                offCount++;
            }
            else
            {
                allGoodsOff = NO;
                model.isSelect = !_allChooseBtn.selected;
            }
            
        }
        if (offCount == goodsList.count)
        {
            form.isSelect = NO;
        }
        else
        {
            form.isSelect = !_allChooseBtn.selected;
        }
    }
    if (!allGoodsOff) {
        _allChooseBtn.selected = !_allChooseBtn.selected;
        [self.myTableView reloadData];
        [self calculateTotalPrice];
    }
    else
    {
        [CZJUtils tipWithText:@"购物车商品均无货" andView:nil];
    }
}

@end
