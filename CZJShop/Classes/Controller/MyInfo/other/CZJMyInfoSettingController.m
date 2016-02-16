//
//  CZJMyInfoSettingController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoSettingController.h"
#import "CZJCouponsCell.h"

@interface CZJMyInfoSettingController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSArray* settingAry;
}
//创建TableView，注册Cell
@property (strong, nonatomic)UITableView* myTableView;
- (IBAction)exitLoginAction:(id)sender;

@end

@implementation CZJMyInfoSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)initViews
{
    settingAry = @[@"推送消息",
                   @"引导页",
                   @"清除本地缓存",
                   @"检测新版本",
                   @"关于车之健"
                   ];
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, 250) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.backgroundColor = CZJNAVIBARGRAYBG;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCouponsCell"];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CZJCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
    cell.couponNameLabel.textColor = [UIColor blackColor];
    cell.couponNameLabel.font = SYSTEMFONT(16);
    cell.chooseButton.hidden = YES;
    cell.couponNameLabel.text = settingAry[indexPath.row];
    NSString* versionStr = settingAry[indexPath.row];
    CGSize size = [CZJUtils calculateTitleSizeWithString:versionStr AndFontSize:16];
    cell.coupontNameWidth.constant = size.width + 10;
    if (0 == indexPath.row)
    {
        cell.arrowImg.hidden = YES;
        cell.chooseButton.hidden = NO;
        [cell.chooseButton addTarget:self action:@selector(pushAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (3 == indexPath.row)
    {
        CGRect rec = CGRectMake(20 + size.width, 18, 100, 14);
        UILabel* versionLabel = [[UILabel alloc]initWithFrame:rec];
        versionLabel.font = SYSTEMFONT(12);
        versionLabel.text = [NSString stringWithFormat:@"(%@)",@"4.0"];
        versionLabel.textAlignment = NSTextAlignmentLeft;
        versionLabel.textColor = [UIColor grayColor];
        [cell addSubview:versionLabel];
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
    if (4 == indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueToAboutUs" sender:self];
    }
}


- (void)pushAction:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
}

- (IBAction)exitLoginAction:(id)sender
{
}
@end
