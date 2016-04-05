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
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
}
@property (strong, nonatomic)NSMutableArray* cardList;
@property (strong, nonatomic)UITableView* myTableView;
@end
@implementation CZJMyWalletCardListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initViews];
}

- (void)initMyDatas
{
    _cardList = [NSMutableArray array];
    page = 1;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
}

- (void)initViews
{
    CGRect viewRect = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT- 128);
    _myTableView = [[UITableView alloc]initWithFrame:viewRect style:UITableViewStylePlain];
    _myTableView.backgroundColor = WHITECOLOR;
    _myTableView.tableFooterView = [[UIView alloc]init];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.bounces = YES;
    [self.view addSubview:_myTableView];
    
    UINib *nib = [UINib nibWithNibName:@"CZJMyWalletCardCell" bundle:nil];
    [_myTableView registerNib:nib forCellReuseIdentifier:@"CZJMyWalletCardCell"];
    
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weak getCardListFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
    
}

- (void)getCardListFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [_params setValue:@(page) forKey:@"page"];
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [_cardList addObjectsFromArray: [CZJMyCardInfoForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 20)
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
            _cardList = [[CZJMyCardInfoForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
        }
        
        if (_cardList.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有对应套餐卡/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (_cardList.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }

    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getCardListFromServer];
        }];
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
        return 230;
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

@end


@implementation CZJMyWalletCardUnUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    _params = @{@"type":@"0", @"page":@"1"};
    [self getCardUnUsedListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMyWalletCardUsedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    _params = @{@"type":@"1", @"page":@"1"};
    [self getCardUsedListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end