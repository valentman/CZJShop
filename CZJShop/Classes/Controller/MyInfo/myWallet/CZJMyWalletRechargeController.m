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

@interface CZJMyWalletRechargeController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* _orderTypeAry; 
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
    CZJOrderTypeForm* zhifubao = [[CZJOrderTypeForm alloc]init];
    zhifubao.orderTypeName = @"支付宝";
    zhifubao.orderTypeImg = @"commit_icon_zhifubao";
    zhifubao.isSelect = YES;
    CZJOrderTypeForm* weixin = [[CZJOrderTypeForm alloc]init];
    weixin.orderTypeName = @"微信支付";
    weixin.orderTypeImg = @"commit_icon_weixin";
    weixin.isSelect = NO;
    CZJOrderTypeForm* uniCard = [[CZJOrderTypeForm alloc]init];
    uniCard.orderTypeName = @"银联支付";
    uniCard.orderTypeImg = @"commit_icon_yinlian";
    uniCard.isSelect = NO;
    _orderTypeAry = @[zhifubao,weixin,uniCard];
    
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
    return 3;
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
        }
    }
    [self.myTableView reloadData];
}


- (IBAction)confirmAction:(id)sender
{
    NSDictionary* params = @{};
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        
    } andServerAPI:kCZJServerAPIRecharge];
}

- (IBAction)numberChooseAction:(id)sender
{
    self.rechargeTextField.text = [NSString stringWithFormat:@"%ld",((UIButton*)sender).tag];
}
@end
