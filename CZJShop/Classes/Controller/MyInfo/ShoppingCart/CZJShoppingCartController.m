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
#import "UIImageView+WebCache.h"
#import "CZJReceiveCouponsController.h"
#import "CZJNaviagtionBarView.h"
#import "CZJCommitOrderController.h"

@interface CZJShoppingCartController ()
<
CZJShoppingCartCellDelegate,
CZJShoppingCartHeaderCellDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* shoppingInfos;
    NSInteger _selectedCount;
    NSMutableArray* _settleOrderAry;
}
@property (weak, nonatomic) IBOutlet PullTableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *settleBtn;
@property (weak, nonatomic) IBOutlet UIButton *allChooseBtn;
@property (weak, nonatomic) IBOutlet UILabel *allChooseLabel;
@property (weak, nonatomic) IBOutlet UILabel *addUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *addUpNumLabel;


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

- (void)initDatas
{
    shoppingInfos = [NSMutableArray array];
    _selectedCount = 0;
}

- (void)initViews
{
    //tableview
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    UINib* nib1 = [UINib nibWithNibName:@"CZJShoppingCartCell" bundle:nil];
    UINib* nib2 = [UINib nibWithNibName:@"CZJShoppingCartHeaderCell" bundle:nil];
    [self.myTableView registerNib:nib1 forCellReuseIdentifier:@"CZJShoppingCartCell"];
    [self.myTableView registerNib:nib2 forCellReuseIdentifier:@"CZJShoppingCartHeaderCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    //自定义导航栏左右按钮
    //左按钮
    UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(- 20 , 0 , 44 , 44 )];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_backnor"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backToLastView:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    if ((IS_IOS7 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -20 ;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, leftItem];
        
    } else
    {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    
    
    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitle:@"完成" forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: rightBtn];
    if ((IS_IOS7 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = 0 ;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
        
    } else
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle.png") forState:UIControlStateNormal];
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle_sel.png") forState:UIControlStateSelected];
    _allChooseBtn.selected = YES;
}


- (void)getShoppingCartInfoFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        [shoppingInfos removeAllObjects];
        shoppingInfos = [[CZJBaseDataInstance shoppingCartForm] shoppingCartList];
        [self.myTableView reloadData];
        [self calculateTotalPrice];
    };
    [CZJBaseDataInstance loadShoppingCart:nil
                                     type:CZJHomeGetDataFromServerTypeOne
                                  Success:successBlock
                                     fail:nil];
}

//计算总价
- (void)calculateTotalPrice
{
    float num = 0.00;
    for (int i=0; i<shoppingInfos.count; i++) {
        NSArray* goodsInfos = ((CZJShoppingCartInfoForm*)shoppingInfos[i]).items;
        for (int j = 0; j<goodsInfos.count; j++) {
            CZJShoppingGoodsInfoForm *model = goodsInfos[j];
            NSInteger count = [model.itemCount integerValue];
            float sale = [model.currentPrice floatValue];
            if (model.isSelect && !model.off)
            {
                num = count*sale+ num;
            }
        }
    }
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
    // Dispose of any resources that can be recreated.
}


#pragma mark- ClickEventCallback
- (void)backToLastView:(id)sender
{
    [((CZJNaviagtionBarView*)self.delegate) refreshShopBadgeLabel];
    [self.delegate didCancel:self];
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
        NSArray* goodsList = form.items;
        for (int j=0; j<goodsList.count; j++)
        {
            CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)goodsList[j];
            if (!model.isSelect && !model.off)
            {//如果门店子物品有一个未被选中或者不能购买，都不能算门店所有物品全选
                form.isSelect = NO;
                self.allChooseBtn.selected = NO;
                break;
            }
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
            [cell setModels:goodsInfo];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdit || indexPath.row == 0)
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
            [CZJBaseDataInstance loadShoppingCartCount:nil Success:nil fail:nil];
            model.isSelect=NO;
            [goodsList.items removeObjectAtIndex:indexPath.row - 1];
            
            if (0 == goodsList.items.count ){
                [shoppingInfos removeObjectAtIndex:indexPath.section];
                [self.myTableView reloadData];
            }
            else
            {
                [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }

        } fail:^{
            //删除失败
        }];
    }
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
    for (int i =0; i<goodsList.count; i++)
    {
        CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)goodsList[i];
        if (cellAllChooseBtn.selected)
        {
            form.isSelect = YES;
        }
        else
        {
            form.isSelect = NO;
        }
        
        if (model.off)
        {
            continue;
        }
        else
        {
            model.isSelect=cellAllChooseBtn.selected;
        }
    }
    
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    [self calculateTotalPrice];
    [self pitchOn];
}

- (void)clickGetCoupon:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    CGRect popViewRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    __weak typeof(self) weak = self;
    [receiveCouponsController setCancleBarItemHandle:^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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

- (void)tapAction{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.window.frame = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 200);
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
            [CZJBaseDataInstance loadShoppingCartCount:nil Success:nil fail:nil];
            
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
                if (model.isSelect==YES && model.off != YES) {
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
                                            @"selfFlag" : form.selfFlag ? @"true" : @"false"
                                            };
                [_settleOrderAry addObject:storeDict];
            }
            
        }
        [self performSegueWithIdentifier:@"segueToSettle" sender:nil];
    }
}

- (IBAction)allChooseAction:(id)sender
{
    _allChooseBtn.selected = !_allChooseBtn.selected;
    BOOL isSelected = _allChooseBtn.selected;
    
    for (int i =0; i<shoppingInfos.count; i++) {
        CZJShoppingCartInfoForm* form = shoppingInfos[i];
        form.isSelect = isSelected;
        NSArray *goodsList = form.items;
        for (int j = 0; j<goodsList.count; j++)
        {
            CZJShoppingGoodsInfoForm *model = goodsList[j];
            model.isSelect=isSelected;
        }
    }
    [self.myTableView reloadData];
    [self calculateTotalPrice];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToSettle"])
    {
        CZJCommitOrderController* settleOrder = segue.destinationViewController;
        settleOrder.settleParamsAry = _settleOrderAry;
    }
}
@end
