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

    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
}
@property (strong, nonatomic)NSMutableArray* orderList;
@property (strong, nonatomic)UITableView* myTableView;
@property (assign, nonatomic) NSInteger page;
@end

@implementation CZJOrderListBaseController
@synthesize params = _params;
- (void)viewDidLoad {
    [super viewDidLoad];
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
    _orderList = [NSMutableArray array];
    _params = [NSMutableDictionary dictionary];
    self.page = 1;
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114);
    if ([[_params valueForKey:@"type"] isEqualToString:@"1"])
    {
        viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 114 - 60);
        CGRect buttomRect = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH,60);
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
    _myTableView.backgroundColor = WHITECOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    UINib *nib = [UINib nibWithNibName:@"CZJOrderListCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJOrderListCell"];
    
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        weak.page++;
        [weak getOrderListFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
}

- (void)getOrderListFromServer
{
    __weak typeof(self) weak = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.completionBlock = ^{
    };
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [_params setValue:@(self.page) forKey:@"page"];
    [CZJBaseDataInstance getOrderList:_params Success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [_orderList addObjectsFromArray: [CZJOrderListForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
            }
        }
        else
        {
            _orderList = [[CZJOrderListForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
            if (_orderList.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
        }

        //========获取数据返回,刷新表格==========
        if (_orderList.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:_noDataPrompt];
        }
        else
        {
            self.myTableView.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
            if ([[_params valueForKey:@"type"] isEqualToString:@"1"])
            {
                _noPayButtomView = [CZJUtils getXibViewByName:@"CZJOrderListNoPayButtomView"];
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _noPayButtomView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT- 114 - 60, PJ_SCREEN_WIDTH,60);
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
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
    _noPayButtomView.totalLabel.text = [NSString stringWithFormat:@"￥%.2f",totalToPay];
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
    _noPayButtomView.totalLabel.text = [NSString stringWithFormat:@"￥%.2f",totalToPay];
    [self.delegate clickOrderListCellButton:btn
                              andButtonType:CZJOrderListCellBtnTypeSelectToPay
                               andOrderForm:orderListForm];
}
@end



@implementation CZJOrderListAllController

- (void)viewDidLoad {
    [self initMyDatas];
    _noDataPrompt = @"无任何订单";
    _params = [@{@"type":@"0", @"page":@"1", @"timeType":@"0"}mutableCopy];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoPayController

- (void)viewDidLoad {
    [self initMyDatas];
    _noDataPrompt = @"无待付款订单";
    _params = [@{@"type":@"1", @"page":@"1", @"timeType":@"0"}mutableCopy];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoBuildController

- (void)viewDidLoad {
    [self initMyDatas];
    _noDataPrompt = @"无待施工订单";
    _params = [@{@"type":@"2", @"page":@"1", @"timeType":@"0"}mutableCopy];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoReceiveController

- (void)viewDidLoad {
    [self initMyDatas];
    _noDataPrompt = @"无待收货订单";
    _params = [@{@"type":@"3", @"page":@"1", @"timeType":@"0"}mutableCopy];
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJOrderListNoEvaController

- (void)viewDidLoad {
    [self initMyDatas];
    _noDataPrompt = @"无评价订单";
    _params = [@{@"type":@"4", @"page":@"1", @"timeType":@"0"}mutableCopy];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
