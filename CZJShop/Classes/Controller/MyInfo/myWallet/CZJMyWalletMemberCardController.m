//
//  CZJMyWalletMemberCardController.m
//  CZJShop
//
//  Created by Joe.Pen on 5/20/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletMemberCardController.h"
#import "CZJCardCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMyWalletMemberCardController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray* memberCardAry;
}
//创建TableView，注册Cell
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyWalletMemberCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self getMemberCardInfoFromServer];
}

- (void)initView
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"我的会员卡";
    self.naviBarView.buttomSeparator.hidden = YES;
    
    //右按钮
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(PJ_SCREEN_WIDTH - 100 , 0 , 100 , 44 );
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn setTitle:@"使用说明" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    [rightBtn setTag:2999];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    [self.naviBarView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(showCardHint:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCardCell"];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getMemberCardInfoFromServer
{
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        memberCardAry = [NSArray arrayWithArray:[dict valueForKey:@"msg"]];
        [_myTableView reloadData];
    } fail:^{
        
    } andServerAPI:kCZJServerAPIGetMemberCards];
}

- (void)showCardHint:(id)sender
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = [NSString stringWithFormat:@"%@%@",kCZJServerAddr,MemberCard_HINT];
    [self.navigationController pushViewController:webView animated:YES];
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
    return memberCardAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict = memberCardAry[indexPath.row];
    CZJCardCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCardCell" forIndexPath:indexPath];
    cell.pointCardView.hidden = YES;
    
    [cell.bgImg setImage:IMAGENAMED(@"vip_img_base")];
    [cell.bgImg setTintColor:WHITECOLOR];
    
    cell.vipLabel.hidden = NO;
    cell.storeName.text = [dict valueForKey:@"storeName"];
    cell.storeName.textColor = WHITECOLOR;
    
    cell.memberNumLabel.text = [NSString stringWithFormat:@"￥%@",[dict valueForKey:@"cardMoney"]];
    cell.memberNumLabel.keyWordFont = SYSTEMFONT(12);
    cell.memberNumLabel.keyWord = @"￥";
    
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

@end
