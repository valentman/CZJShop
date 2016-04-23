//
//  CZJDiscoverViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/1/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDiscoverController.h"
#import "CZJBaseDataManager.h"
#import "CZJLoginModelManager.h"
#import "CZJDiscoverDetailController.h"
#import "CZJGeneralCell.h"
#import "CZJScanQRController.h"

#define kTypeLabelTag 10
#define kNewsLabelTag 11
#define kDotViewTag 12

@interface CZJDiscoverViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* cellTypesAry;
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableDictionary* discoverForms;
@end

@implementation CZJDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getDataFromServer];
    self.discoverForms = [NSMutableDictionary dictionary];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeMain];
    self.naviBarView.btnMore.hidden = YES;
    self.naviBarView.mainTitleLabel.text = @"发现";
    
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = WHITECOLOR;
    [self.view addSubview:self.myTableView];
    NSArray* nibArys = @[@"CZJGeneralCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    
    NSDictionary* cell1 = @{@"title":@"活动中心", @"detailTitle":@"activity",  @"buttonTitle":@"find_icon_activity.png"} ;
    NSDictionary* cell2 = @{@"title":@"汽车资讯", @"detailTitle":@"news", @"buttonTitle":@"find_icon_news.png"} ;
    NSDictionary* cell3 = @{@"title":@"扫一扫", @"detailTitle":@"shake", @"buttonTitle":@"find_icon_saoyisao.png"} ;
    cellTypesAry = @[cell1, cell2, cell3];
}


- (void)getDataFromServer
{
    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        [self.discoverForms setValuesForKeysWithDictionary:CZJBaseDataInstance.discoverForms];
        [self updateTableView];
    };
    
    CZJFailureBlock failBlock = ^{};
    [CZJBaseDataInstance showDiscoverWithBlocksuccess:successBlock fail:failBlock];
}



- (void)viewDidAppear:(BOOL)animated
{
    NSArray* cells = [self.myTableView visibleCells];
    for (id cell in cells) {
        UIView* dotTagView = [[cell contentView]viewWithTag:kDotViewTag];
        dotTagView.layer.cornerRadius = 2.5;
    }
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
    if (1 == section)
    {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict;
    if (0 == indexPath.section)
    {
        dict = cellTypesAry[indexPath.row];
    }
    else
    {
        dict = cellTypesAry[2];
    }
    CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
    [cell.nameLabel setTag:kTypeLabelTag];
    [cell.detailLabel setTag:kNewsLabelTag];
    cell.imageViewHeight.constant = 29;
    cell.imageViewWidth.constant = 29;
    [cell.headImgView setImage:IMAGENAMED([dict valueForKey:@"buttonTitle"])];
    cell.nameLabel.text = [dict valueForKey:@"title"];
    cell.tempData = [dict valueForKey:@"detailTitle"];

    if (1 == indexPath.section && 0 == indexPath.row)
    {
        cell.separatorInset = HiddenCellSeparator;
    }
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSString* url = @"";
        if (0 == indexPath.row && 0 == indexPath.section)
        {
            
            url = [NSString stringWithFormat:@"%@?chezhuId=%@",[CZJUtils getExplicitServerAPIURLPathWithSuffix:kCZJServerAPIActivityCenter],CZJLoginModelInstance.usrBaseForm.chezhuId];
        }
        if (1 == indexPath.row && 0 == indexPath.section)
        {
            url = [NSString stringWithFormat:@"%@?chezhuId=%@",[CZJUtils getExplicitServerAPIURLPathWithSuffix:kCZJServerAPICarInfo],CZJLoginModelInstance.usrBaseForm.chezhuId];
        }
        
        CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
        webView.cur_url = url;
        [self.navigationController pushViewController:webView animated:YES];
        
        CZJGeneralCell* cell = (CZJGeneralCell*)[tableView cellForRowAtIndexPath:indexPath];
        UIView* dotTagView = VIEWWITHTAG(cell.contentView, kDotViewTag);
        dotTagView.hidden = YES;
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJScanQRController* scanVC = (CZJScanQRController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDScanQR];
            [self.navigationController pushViewController:scanVC animated:YES];
        }
    }
}


- (void)updateTableView
{
    NSArray* cells = [self.myTableView visibleCells];
    for (CZJGeneralCell* cell in cells) {
        UIView* dotTagView = [[cell contentView]viewWithTag:kDotViewTag];
        NSString* reuseID = cell.tempData;
        NSString* newsBody = [[self.discoverForms valueForKey:reuseID]valueForKey:@"desc"];
        if ([newsBody isEqualToString:@""]) {
            DLog(@"%@",reuseID);
            dotTagView.hidden = YES;
            return;
        }
        cell.detailLabel.hidden = NO;
        cell.detailLabel.text = newsBody;
        
        NSString* updatetime = [[self.discoverForms valueForKey:reuseID] valueForKey:@"updateTime"];
        NSString* value = [USER_DEFAULT valueForKey:reuseID];
        if (!value)
        {
            [USER_DEFAULT setValue:updatetime forKey:reuseID];
            dotTagView.hidden = NO;
        }
        else if ([value isEqualToString:updatetime])
        {
            dotTagView.hidden = YES;
        }
        else
        {
            DLog(@"%@",reuseID);
            dotTagView.hidden = NO;
        }
    }
}


- (void)dealWithDotTagView:(CZJTableViewCell*)_cell andUpdateTime:(NSString*)_updateTime
{
    
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


@end


@implementation CZJDiscoverForm

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.newsBody = [dic valueForKey:@"desc"];
        self.newsUpdateTime = [dic valueForKey:@"updateTime"];
        return self;
    }
    return nil;
}

@end