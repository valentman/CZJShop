//
//  CZJPopPayViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJPopPayViewController.h"
#import "CZJOrderForm.h"
#import "CZJOrderTypeCell.h"
#import "CZJOrderListPayCell.h"
#import "CZJBaseDataManager.h"

@interface CZJPopPayViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJOrderListPayCellDelegate
>
{
    NSArray* _orderTypeAry;
    CZJOrderTypeForm* _selectedTypeForm;
}
@end

@implementation CZJPopPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeaderView];
    [self initTableView];
}

- (void)initHeaderView
{
    self.contentHeight = 0;
    //弹出框顶部标题
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH/2 - 50, 15, 100, 21)];
    title.font=[UIFont systemFontOfSize:15];
    title.textColor=[UIColor blackColor];
    title.text = @"选择支付方式";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    //右上角叉叉退出按钮
    UIButton* _exitBt = [[UIButton alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 44, 5, 44, 44)];
    [_exitBt addTarget:self action:@selector(exitTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_exitBt setImage:IMAGENAMED(@"prodetail_icon_off") forState:UIControlStateNormal];
    [self.view addSubview:_exitBt];
    
    //底部分割线
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 50, PJ_SCREEN_WIDTH, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    self.contentHeight = 50;
}

- (void)initTableView
{
    _orderTypeAry = CZJBaseDataInstance.orderPaymentTypeAry;
    for (CZJOrderTypeForm* form in _orderTypeAry)
    {
        if ([form.orderTypeName isEqualToString:@"支付宝支付"])
        {
            _selectedTypeForm = form;
            break;
        }
    }
    //添加TableView
    CGRect rect = [self.view bounds];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50.5, PJ_SCREEN_WIDTH, rect.size.height - 50) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollsToTop=YES;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    
    NSArray* nibArys = @[@"CZJOrderTypeCell",
                         @"CZJOrderListPayCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:cells];
    }
    [self.tableView reloadData];
    self.contentHeight += self.tableView.mj_contentH;
}

- (void)exitTouch:(id)sender
{
    if(self.basicBlock)self.basicBlock();
}

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock
{
    self.basicBlock = basicBlock;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orderTypeAry.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_orderTypeAry.count == indexPath.row)
    {
        CZJOrderListPayCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderListPayCell" forIndexPath:indexPath];
        cell.orderMoneyLabel.text = [NSString stringWithFormat:@"￥%.2f",self.orderMoney];
        cell.delegate = self;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    else
    {
        CZJOrderTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeCell" forIndexPath:indexPath];
        [cell setOrderTypeForm:_orderTypeAry[indexPath.row]];
        cell.separatorInset = IndentCellSeparator(20);
        if (_orderTypeAry.count - 1 == indexPath.row)
        {
            cell.separatorInset = HiddenCellSeparator;
        }
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_orderTypeAry.count == indexPath.row)
    {
        return 60;
    }
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _orderTypeAry.count)
    {
        for ( int i = 0; i < _orderTypeAry.count; i++)
        {
            CZJOrderTypeForm* typeForm = _orderTypeAry[i];
            typeForm.isSelect = NO;
            if (i == indexPath.row)
            {
                typeForm.isSelect = YES;
                _selectedTypeForm = typeForm;
            }
        }
        [self.tableView reloadData];
    }

}

#pragma mark -CZJOrderListPayCellDelegate
- (void)clickToPay:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(payViewToPay:)])
    {
        [self.delegate payViewToPay:_selectedTypeForm];
    }
}

@end
