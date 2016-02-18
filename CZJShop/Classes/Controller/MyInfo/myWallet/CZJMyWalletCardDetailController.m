//
//  CZJMyWalletCardDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCardDetailController.h"
#import "CZJMyWalletCardCell.h"
#import "CZJRedPacketUseCaseCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMyWalletCardDetailController ()
<
UITableViewDataSource,
UITableViewDelegate
>
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyWalletCardDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
    [self getCardDetailInfoFromServer];
}

- (void)initViews
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CLEARCOLOR;
    [self.view addSubview:self.myTableView];
    self.view.backgroundColor = CZJNAVIBARGRAYBG;
    
    NSArray* nibArys = @[@"CZJMyWalletCardCell",
                         @"CZJRedPacketUseCaseCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getCardDetailInfoFromServer
{
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
    {
        return 10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        CZJMyWalletCardCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyWalletCardCell" forIndexPath:indexPath];
        cell.storeNameLabel.text = _cardInfoForm.storeName;
        cell.cardTypeLabel.text = _cardInfoForm.setmenuName;
        [cell setCardCellWithCardDetailInfo:_cardInfoForm];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        CZJRedPacketUseCaseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketUseCaseCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return  160 + 35 * _cardInfoForm.items.count;
    }
    return 100;
}

@end
