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

@interface CZJShoppingCartController ()
<
CZJShoppingCartCellDelegate,
CZJShoppingCartHeaderCellDelegate
>
{
    NSMutableArray* shoppingInfos;
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
    };
    [CZJBaseDataInstance loadShoppingCart:nil Success:successBlock fail:nil];
}

//计算总价
- (void)calculateTotalPrice
{
    float num = 0.00;
    for (int i=0; i<shoppingInfos.count; i++) {
        CZJShoppingCartInfoForm* _shoppingcartInfo = (CZJShoppingCartInfoForm*)shoppingInfos[i];
        NSArray* goodsInfos = _shoppingcartInfo.items;
        
        for (int j = 0; j<goodsInfos.count-1; j++) {
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- ClickEventCallback
- (void)backToLastView:(id)sender
{
    [self.delegate didCancel:self];
}


- (void)edit:(id)sender
{
    UIButton* itemButton = (UIButton*)sender;
    itemButton.selected = !itemButton.selected;
    self.isEdit = !self.isEdit;
    if (self.isEdit)
    {
        self.settleBtn.titleLabel.text = @"删除";
    }
    else
    {
        self.settleBtn.titleLabel.text = @"提交订单";
    }
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
    DLog(@"", ((CZJShoppingCartInfoForm*)shoppingInfos[section]).items.count);
    return ((CZJShoppingCartInfoForm*)shoppingInfos[section]).items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJShoppingCartInfoForm* _shoppingcartInfo = (CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section];
    if (0 == indexPath.row) {
        CZJShoppingCartHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJShoppingCartHeaderCell" forIndexPath:indexPath];
        if (shoppingInfos.count > 0)
        {
            [cell setModels:_shoppingcartInfo];
        }
        return cell;
    }
    else
    {
        CZJShoppingGoodsInfoForm* goodsInfo = (CZJShoppingGoodsInfoForm*)_shoppingcartInfo.items[indexPath.row -1];
        CZJShoppingCartCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJShoppingCartCell" forIndexPath:indexPath];
        if (goodsInfo)
        {
            [cell setModels:goodsInfo];
        }
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
    if (self.isEdit)
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
        NSMutableArray *goodsList = [shoppingInfos objectAtIndex:indexPath.section];
        
        CZJShoppingCartInfoForm *model = [ goodsList objectAtIndex:indexPath.row];
        model.isSelect=NO;
        [goodsList removeObjectAtIndex:indexPath.row];
        
        if (0 == goodsList.count ){
            [shoppingInfos removeObjectAtIndex:indexPath.section];
        }
        
        [self.myTableView reloadData];
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
    CZJShoppingCartInfoForm* form = (CZJShoppingCartInfoForm*)shoppingInfos[indexPath.section];
    NSArray* goodsList = form.items;
    for (int i =0; i<goodsList.count; i++)
    {
        CZJShoppingGoodsInfoForm *model = (CZJShoppingGoodsInfoForm *)goodsList[i];
        if (_allChooseBtn.selected)
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
            model.isSelect=_allChooseBtn.selected;
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark- 结算按钮
- (IBAction)settleActioin:(id)sender
{
    if (self.isEdit)
    {
        //删除
        for (int i = 0; i<shoppingInfos.count; i++) {
            CZJShoppingCartInfoForm* form = shoppingInfos[i];
            NSMutableArray* goodsList = form.items;
            for (int j=0 ; j<goodsList.count; j++) {
                CZJShoppingGoodsInfoForm *model = goodsList[j];
                if (model.isSelect==YES) {
                    [goodsList removeObjectAtIndex:j];
                    continue;
                }
            }
            if (goodsList.count<=1) {
                [shoppingInfos removeObjectAtIndex:i];
            }
        }
        [self.myTableView reloadData];
    }
    else
    {
        
    }
}

- (IBAction)allChooseAction:(id)sender
{
    _allChooseBtn.selected = !_allChooseBtn.selected;
    BOOL isSelected = _allChooseBtn.selected;
    
    if (isSelected)
    {
        _allChooseLabel.text = @"全选";
    }
    else
    {
        _allChooseLabel.text = @"取消全选";
    }
    
    for (int i =0; i<shoppingInfos.count; i++) {
        CZJShoppingCartInfoForm* form = shoppingInfos[i];
        form.isSelect = isSelected;
        NSArray *goodsList = form.items;
        for (int j = 0; j<goodsList.count-1; j++)
        {
            CZJShoppingGoodsInfoForm *model = goodsList[j];
            model.isSelect=isSelected;
        }
    }
    [self.myTableView reloadData];
}
@end
