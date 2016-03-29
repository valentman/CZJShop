//
//  CZJMyWalletRedpacketController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletRedpacketController.h"
#import "CZJBaseDataManager.h"
#import "CZJRedPacketUseCaseCell.h"

@interface CZJMyWalletRedpacketController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation CZJMyWalletRedpacketController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
    [self getRedPacketInfoFromSever];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = YES;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.backgroundColor = CLEARCOLOR;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray* nibArys = @[@"CZJRedPacketUseCaseCell"];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getRedPacketInfoFromSever
{
    NSDictionary* params = @{};
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getRedPacketInfoFromSever];
        }];
    } andServerAPI:nil];
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJRedPacketUseCaseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketUseCaseCell" forIndexPath:indexPath];
    [cell setRedPacketCellWithData:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
