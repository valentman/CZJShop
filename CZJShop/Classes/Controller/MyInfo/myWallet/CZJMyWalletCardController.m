//
//  CZJMyWalletCardController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCardController.h"
#import "CZJMyWalletCardDetailController.h"
#import "CZJPageControlView.h"
#import "PullTableView.h"
#import "CZJMyWalletCardCell.h"
#import "CZJBaseDataManager.h"
#import "CZJMyCardInfoForm.h"

@interface CZJMyWalletCardController ()<CZJMyWalletCardListCellDelegate>
{
    CZJMyCardInfoForm* cardForm;
}
@end

@implementation CZJMyWalletCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    CZJMyWalletCardUnUsedController* unUsed = [[CZJMyWalletCardUnUsedController alloc]init];
    CZJMyWalletCardUsedController* used = [[CZJMyWalletCardUsedController alloc]init];
    unUsed.delegate = self;
    used.delegate = self;
    CGRect pageViewFrame = CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT);
    CZJPageControlView* pageview = [[CZJPageControlView alloc]initWithFrame:pageViewFrame andPageIndex:0];
    [pageview setTitleArray:@[@"未用完",@"已用完"] andVCArray:@[unUsed, used]];
    pageview.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:pageview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickCardWithData:(id)data
{
    cardForm = data;
    [self performSegueWithIdentifier:@"segueToCardDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CZJMyWalletCardDetailController* detailController = segue.destinationViewController;
    detailController.cardInfoForm = cardForm;
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
@property (strong, nonatomic)NSArray* cardList;
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
    
    _myTableView.backgroundColor = CZJTableViewBGColor;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJMyWalletCardCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJMyWalletCardCell"];
}

- (void)getCardListFromServer
{
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        NSArray* dict = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
        _cardList = [CZJMyCardInfoForm objectArrayWithKeyValuesArray:dict];
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        self.myTableView.pullDelegate = self;
        [self.myTableView reloadData];
    } andServerAPI:kCZJServerAPIShowCardList];
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
    return _cardList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCardInfoForm* form = (CZJMyCardInfoForm*)_cardList[indexPath.row];
    CZJMyWalletCardCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyWalletCardCell" forIndexPath:indexPath];
    cell.storeNameLabel.text = form.storeName;
    cell.cardTypeLabel.text = form.setmenuName;
    cell.cardTypeWidth.constant = [CZJUtils calculateTitleSizeWithString:form.setmenuName AndFontSize:17].height + 5;
    if (form.items.count > 0)
    {
        CZJMyCardDetailInfoForm* cardDetailForm = form.items[0];
        CGSize labelSize = [CZJUtils calculateStringSizeWithString:cardDetailForm.itemName Font:SYSTEMFONT(11) Width:200];
        cell.itemNameLabelWidth.constant = labelSize.width + 5;
        cell.itemNameLabel.text = cardDetailForm.itemName;
        cell.totalTimeLabel.text = cardDetailForm.itemCount;
        cell.leftTimeLabel.text = [NSString stringWithFormat:@"%ld",[cardDetailForm.itemCount integerValue] - [cardDetailForm.useCount integerValue]];
    }
    cell.tintColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCardInfoForm* form = (CZJMyCardInfoForm*)_cardList[indexPath.row];
    if (form.items.count > 0)
    {
        return 250;
    }
    return 181;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCardInfoForm* form = (CZJMyCardInfoForm*)_cardList[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(clickCardWithData:)])
    {
        [self.delegate clickCardWithData:form];
    }
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
    _params = @{@"type":@"0", @"page":@"1"};
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
    _params = @{@"type":@"1", @"page":@"1"};
    [super getCardListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end