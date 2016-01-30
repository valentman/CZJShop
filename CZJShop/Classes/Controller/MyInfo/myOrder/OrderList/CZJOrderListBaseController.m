//
//  CZJOrderListBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListBaseController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderListCell.h"
#import "PullTableView.h"
#import "CZJMyOrderDetailController.h"

@interface CZJOrderListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate,
PullTableViewDelegate
>
{

}
@property (strong, nonatomic)NSMutableArray* orderList;
@property (strong, nonatomic)PullTableView* myTableView;
@end

@implementation CZJOrderListBaseController
@synthesize params = _params;
- (void)viewDidLoad {
    [super viewDidLoad];
    _orderList = [NSMutableArray array];
    [self initViews];
    DLog(@"主线程线程----%@",[NSThread currentThread]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog();
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 128);
    _myTableView = [[PullTableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJOrderListCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJOrderListCell"];
}

- (void)getOrderListFromServer
{
    [CZJBaseDataInstance getOrderList:_params Success:^(id json) {
        DLog(@"请求网络返回");
        _orderList = [[CZJOrderListForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg" ]] mutableCopy];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.pullDelegate = self;
        [_myTableView reloadData];
    } fail:^{
        
    }];
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

#pragma mark- pullTableviewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    
}

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


@end
