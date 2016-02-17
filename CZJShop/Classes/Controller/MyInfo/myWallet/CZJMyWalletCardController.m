//
//  CZJMyWalletCardController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCardController.h"
#import "CZJPageControlView.h"
#import "PullTableView.h"
#import "CZJMyWalletCardCell.h"

@interface CZJMyWalletCardController ()

@end

@implementation CZJMyWalletCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)initViews
{
    CZJMyWalletCardUnUsedController* unUsed = [[CZJMyWalletCardUnUsedController alloc]init];
    CZJMyWalletCardUsedController* used = [[CZJMyWalletCardUsedController alloc]init];
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageview setTitleArray:@[@"未用完",@"已用完"] andVCArray:@[unUsed, used]];
    [self.view addSubview:pageview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



@interface CZJMyWalletCardListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate,
PullTableViewDelegate
>
{
    
}
@property (strong, nonatomic)NSMutableArray* cardList;
@property (strong, nonatomic)PullTableView* myTableView;
@end
@implementation CZJMyWalletCardListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cardList = [NSMutableArray array];
    [self initViews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.myTableView.pullTableIsRefreshing = NO;
    self.myTableView.pullTableIsLoadingMore = NO;
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 128);
    _myTableView = [[PullTableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    
    _myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJMyWalletCardCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJMyWalletCardCell"];
}

- (void)getCardListFromServer
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cardList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 216;
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

@end


@implementation CZJMyWalletCardUnUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCardUnUsedListFromServer];
}

- (void)getCardUnUsedListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getCardListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMyWalletCardUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCardUsedListFromServer];
}

- (void)getCardUsedListFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getCardListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end