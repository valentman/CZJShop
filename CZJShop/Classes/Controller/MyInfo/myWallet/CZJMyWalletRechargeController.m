//
//  CZJMyWalletRechargeController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletRechargeController.h"
#import "CZJOrderForm.h"
#import "CZJOrderTypeCell.h"
#import "CZJBaseDataManager.h"
#import "CZJPaymentManager.h"

@interface CZJMyWalletRechargeController ()
<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate
>
{
    NSArray* _orderTypeAry;
    CZJOrderTypeForm* _defaultOrderType;        //默认支付方式（为支付宝）
    NSString* finalChargeNumber;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *rechargeTextField;

- (IBAction)confirmAction:(id)sender;
- (IBAction)numberChooseAction:(id)sender;


@end

@implementation CZJMyWalletRechargeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)initViews
{
    _orderTypeAry = CZJBaseDataInstance.orderPaymentTypeAry;
    _defaultOrderType = _orderTypeAry.firstObject;
    
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderTypeCell",
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    [self.myTableView reloadData];
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
    return _orderTypeAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderTypeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderTypeCell" forIndexPath:indexPath];
    [cell setOrderTypeForm:_orderTypeAry[indexPath.row]];
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for ( int i = 0; i < _orderTypeAry.count; i++)
    {
        CZJOrderTypeForm* typeForm = _orderTypeAry[i];
        typeForm.isSelect = NO;
        if (i == indexPath.row)
        {
            typeForm.isSelect = YES;
            _defaultOrderType = typeForm;
        }
    }
    [self.myTableView reloadData];
}


- (IBAction)confirmAction:(id)sender
{
    
    if ([finalChargeNumber floatValue] < 0.001)
    {
        [CZJUtils tipWithText:@"充值金额为0，请输入充值金额" andView:self.view];
        return;
    }
    NSDictionary* params = @{};
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].mode = MBProgressHUDModeIndeterminate;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        DLog(@"服务器请求订单编号返回");
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        [NSThread sleepForTimeInterval:1.0f];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        CZJPaymentOrderForm* paymentOrderForm = [[CZJPaymentOrderForm alloc] init];
        paymentOrderForm.order_no = [dict valueForKey:@"payNo"];
        paymentOrderForm.order_name = [NSString stringWithFormat:@"订单%@",[dict valueForKey:@"payNo"]];
        paymentOrderForm.order_description = @"支付宝你个SB";
        paymentOrderForm.order_price = finalChargeNumber;
        paymentOrderForm.order_for = @"charge";
        if ([_defaultOrderType.orderTypeName isEqualToString:@"微信支付"])
        {
            DLog(@"提交订单页面请求微信支付");
            [CZJPaymentInstance weixinPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"微信支付失败" andView:weak.view];
            }];
        }
        if ([_defaultOrderType.orderTypeName isEqualToString:@"支付宝支付"])
        {
            DLog(@"提交订单页面请求支付宝支付");
            [CZJPaymentInstance aliPay:self OrderInfo:paymentOrderForm Success:^(NSDictionary *message) {
            } Fail:^(NSDictionary *message, NSError *error) {
                [CZJUtils tipWithText:@"支付宝支付失败" andView:weak.view];
            }];
        }
    } andServerAPI:kCZJServerAPIRecharge];
}

- (IBAction)numberChooseAction:(id)sender
{
    self.rechargeTextField.text = [NSString stringWithFormat:@"%ld",((UIButton*)sender).tag];
    finalChargeNumber = self.rechargeTextField.text;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    finalChargeNumber = textField.text;
    DLog(@"%@",finalChargeNumber);
}

@end
