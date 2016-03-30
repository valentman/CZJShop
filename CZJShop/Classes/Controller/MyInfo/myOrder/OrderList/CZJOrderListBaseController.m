//
//  CZJOrderListBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListBaseController.h"
#import "CZJBaseDataManager.h"
#import "CZJMyOrderDetailController.h"


@interface CZJOrderListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJOrderListCellDelegate
>
{
    float totalToPay;
    NSMutableArray* orderNoArys;

}
@property (strong, nonatomic)NSArray* orderList;
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderListBaseController
@synthesize params = _params;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initViews];
    [self getOrderListFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getOrderListFromServer) name:kCZJNotifiRefreshOrderlist object:nil];
}

- (void)removeOrderlistControllerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCZJNotifiRefreshOrderlist object:nil];
}

- (void)initMyDatas
{
    orderNoArys = [NSMutableArray array];
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114);
    if ([[_params valueForKey:@"type"] isEqualToString:@"1"])
    {
        viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114 - 60);
        CGRect buttomRect = CGRectMake(0, PJ_SCREEN_HEIGHT- 114 - 60, PJ_SCREEN_WIDTH,60);
        _noPayButtomView = [CZJUtils getXibViewByName:@"CZJOrderListNoPayButtomView"];
        _noPayButtomView.frame = buttomRect;
        if (iPhone4 || iPhone5)
        {
            _noPayButtomView.goToPayWidth.constant = 100;
        }
        [self.view addSubview:_noPayButtomView];
        [_noPayButtomView.allChooseBtn addTarget:self action:@selector(chooseAllActioin:) forControlEvents:UIControlEventTouchUpInside];
        [_noPayButtomView.goToPayBtn addTarget:self action:@selector(buttomViewGoToPay:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _myTableView = [[UITableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    UINib *nib = [UINib nibWithNibName:@"CZJOrderListCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJOrderListCell"];
}

- (void)getOrderListFromServer
{
    __weak typeof(self) weak = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.completionBlock = ^{
        if (_orderList.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:_noDataPrompt];
        }
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView reloadData];
    };
    
    [CZJBaseDataInstance getOrderList:_params Success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _orderList = [CZJOrderListForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg" ]];
        for (CZJOrderListForm* form in _orderList)
        {
            DLog(@"%@",[form.keyValues description]);
        }
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getOrderListFromServer];
        }];
    }];
}

- (void)buttomViewGoToPay:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showPopPayView:andOrderNoSting:)])
    {
        if (0 == totalToPay) {
            [CZJUtils tipWithText:@"请选择商品" andView:nil];
            return;
        }
        for (CZJOrderListForm* cellForm in _orderList)
        {
            if (cellForm.isSelected)
            {
                [orderNoArys addObject:cellForm.orderNo];
            }
        }
        [self.delegate showPopPayView:totalToPay andOrderNoSting:[orderNoArys componentsJoinedByString:@","]];
    }
}

- (void)chooseAllActioin:(id)sender
{
    UIButton* allchooseBtn =(UIButton*)sender;
    allchooseBtn.selected = !allchooseBtn.selected;
    totalToPay = 0;
    for (CZJOrderListForm* cellForm in _orderList)
    {
        totalToPay += [cellForm.orderMoney floatValue] * (allchooseBtn.selected ? 1 : 0);;
        cellForm.isSelected = allchooseBtn.selected;
    }
    _noPayButtomView.totalLabel.text = [NSString stringWithFormat:@"￥%.1f",totalToPay];
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _orderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderListCell" forIndexPath:indexPath];
    [cell setCellModelWithType:_orderList[indexPath.section] andType:[[_params valueForKey:@"type"] integerValue]];
    cell.delegate = self;
    if (indexPath.section == _orderList.count - 1)
    {
        cell.separatorInset = HiddenCellSeparator;
    }
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 216;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate clickOneOrder:_orderList[indexPath.section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 10;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark- CZJOrderListCellDelegate
- (void)clickOrderListCellAction:(CZJOrderListCellButtonType)buttonType andOrderForm:(CZJOrderListForm*)orderListForm
{
    [self.delegate clickOrderListCellButton:nil
                              andButtonType:buttonType
                               andOrderForm:orderListForm];
}

- (void)clickPaySelectButton:(UIButton*)btn andOrderForm:(CZJOrderListForm*)orderListForm
{
    BOOL allChoose = YES;
    for (CZJOrderListForm* cellForm in _orderList)
    {
        if ([cellForm.orderNo isEqualToString:orderListForm.orderNo])
        {
            cellForm.isSelected = btn.selected;
        }
        if (!cellForm.isSelected)
        {
            allChoose = NO;
        }
    }
    _noPayButtomView.allChooseBtn.selected = allChoose;
    totalToPay += [orderListForm.orderMoney floatValue] * (btn.selected ? 1 : -1);
    _noPayButtomView.totalLabel.text = [NSString stringWithFormat:@"￥%.1f",totalToPay];
    [self.delegate clickOrderListCellButton:btn
                              andButtonType:CZJOrderListCellBtnTypeSelectToPay
                               andOrderForm:orderListForm];
}
@end



@implementation CZJOrderListAllController

- (void)viewDidLoad {
    _noDataPrompt = @"无任何订单";
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoPayController

- (void)viewDidLoad {
    _noDataPrompt = @"无待付款订单";
    _params = @{@"type":@"1", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoBuildController

- (void)viewDidLoad {
    _noDataPrompt = @"无待施工订单";
    _params = @{@"type":@"2", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoReceiveController

- (void)viewDidLoad {
    _noDataPrompt = @"无待收货订单";
    _params = @{@"type":@"3", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoEvaController

- (void)viewDidLoad {
    _noDataPrompt = @"无评价订单";
    _params = @{@"type":@"4", @"page":@"1", @"timeType":@"0"};
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
