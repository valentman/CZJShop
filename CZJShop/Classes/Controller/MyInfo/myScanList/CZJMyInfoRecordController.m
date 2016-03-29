//
//  CZJMyInfoRecordController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoRecordController.h"
#import "CZJBaseDataManager.h"
#import "CZJGoodsAttentionCell.h"

@interface CZJMyInfoRecordController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* scanListAry;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation CZJMyInfoRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getScanListFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    scanListAry = [NSMutableArray array];
    [CZJUtils customizeNavigationBarForTarget:self];
    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"清空" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    [rightBtn setTag:1999];
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: rightBtn];
    if ((IS_IOS7 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = 0 ;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
    } else
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UINib *nib=[UINib nibWithNibName:@"CZJGoodsAttentionCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:@"CZJGoodsAttentionCell"];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    
}

- (void)getScanListFromServer
{
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary* params = @{@"": @""};
    [CZJBaseDataInstance loadScanList:params Success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        [scanListAry removeAllObjects];
        scanListAry = [[dict valueForKey:@"msg"] mutableCopy];
        VIEWWITHTAG(self.navigationController.navigationBar, 1999).hidden = (scanListAry.count == 0);
        if (scanListAry.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有浏览记录/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (scanListAry.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
        }
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getScanListFromServer];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)edit:(id)sender
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确认清除浏览记录？" andConfirmHandler:^{
        [CZJBaseDataInstance clearScanList:nil Success:^(id json) {
            [scanListAry removeAllObjects];
            VIEWWITHTAG(self.navigationController.navigationBar, 1999).hidden = (scanListAry.count == 0);
            self.myTableView.hidden = (scanListAry.count == 0);
            [self.myTableView reloadData];
        } fail:^{
            [CZJUtils tipWithText:@"服务器异常，清除失败" andView:weak.view];
        }];
        [weak hideWindow];
    } andCancleHandler:nil];

}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return scanListAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* form = scanListAry[indexPath.row];
    CZJGoodsAttentionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsAttentionCell" forIndexPath:indexPath];
    [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:[form valueForKey:@"itemImg"]] placeholderImage:DefaultPlaceHolderImage];
    
    CGSize nameSize = [CZJUtils calculateStringSizeWithString:[form valueForKey:@"itemName"] Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 116];
    cell.goodNameLabel.text = [form valueForKey:@"itemName"];
    cell.goodNameLayoutHeight.constant = nameSize.height;
    cell.priceLabel.text = [form valueForKey:@"currentPrice"];
    
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict = scanListAry[indexPath.row];
    [CZJUtils showGoodsServiceDetailView:self.navigationController andItemPid:[dict valueForKey:@"storeItemPid"] detailType:[[dict valueForKey:@"itemType"] intValue] == 0 ? CZJDetailTypeGoods : CZJDetailTypeService];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

@end
