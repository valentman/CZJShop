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
{
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    
    NSMutableArray* redpacketAry;
}
@property (weak, nonatomic) IBOutlet UILabel *redpacketNumLabel;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (assign, nonatomic) NSInteger page;
@property (weak, nonatomic) IBOutlet UIView *verticalSeparatorView;
- (void)useGuideAction:(id)sender;
@end

@implementation CZJMyWalletRedpacketController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    //UIButton
    UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(- 20 , 0 , 88 , 44 )];
    [leftBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [leftBtn setTitle:@"使用说明" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(useGuideAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
    
    //UIBarButtonItem
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self initMyDatas];
    [self initViews];
    [self getRedPacketInfoFromSever];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initMyDatas
{
    self.page = 1;
    redpacketAry = [NSMutableArray array];
    self.redpacketNumLabel.text = self.redPacketNum;
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
    self.myTableView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray* nibArys = @[@"CZJRedPacketUseCaseCell"];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    //添加下拉刷新控件
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        weak.page++;
        [weak getRedPacketInfoFromSever];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
    self.verticalSeparatorView.hidden = YES;
    
}

- (void)getRedPacketInfoFromSever
{
    NSDictionary* params = @{@"page" : @(self.page)};
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        DLog(@"%@",[CZJUtils DataFromJson:json]);
        
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [redpacketAry addObjectsFromArray: [CZJRedpacketInfoForm objectArrayWithKeyValuesArray:tmpAry]];
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
            redpacketAry = [[CZJRedpacketInfoForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
        }
        
        if (redpacketAry.count == 0)
        {
            self.myTableView.hidden = YES;
            self.verticalSeparatorView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有红包使用记录/(ToT)/~~"];
            UIView* subVie = VIEWWITHTAG(self.view, 2525);
            [subVie setPosition:CGPointMake(PJ_SCREEN_WIDTH*0.5, PJ_SCREEN_HEIGHT*0.7) atAnchorPoint:CGPointMiddle];
        }
        else
        {
            self.myTableView.hidden = (redpacketAry.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }
    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getRedPacketInfoFromSever];
        }];
    } andServerAPI:kCZJServerAPIGetRedPacketInfo];
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
    return redpacketAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJRedPacketUseCaseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketUseCaseCell" forIndexPath:indexPath];
    CZJRedpacketInfoForm* redpacketInfoForm = redpacketAry[indexPath.row];
    if ([redpacketInfoForm.value integerValue] > 0)
    {
        cell.leftView.hidden = NO;
        cell.rightView.hidden = YES;
        cell.rightLabel.text = redpacketInfoForm.takeTime;
        cell.leftBalanceLabel.text = redpacketInfoForm.curValue;
        cell.leftItemNameLabel.text = redpacketInfoForm.name;
        cell.leftNumberLabel.text = [NSString stringWithFormat:@"+%@",redpacketInfoForm.value];
    }
    else if ([redpacketInfoForm.value integerValue] < 0)
    {
        cell.leftView.hidden = YES;
        cell.rightView.hidden = NO;
        cell.leftLabel.text = redpacketInfoForm.takeTime;
        cell.rightBalanceLabel.text = redpacketInfoForm.curValue;
        cell.rightItemNameLabel.text = redpacketInfoForm.name;
        cell.rightNumberLabel.text = redpacketInfoForm.value;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)useGuideAction:(id)sender
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = [NSString stringWithFormat:@"%@%@",kCZJServerAddr,REDPACKET_HINT];
    [self.navigationController pushViewController:webView animated:YES];
}
@end
