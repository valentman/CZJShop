//
//  CZJMyCarListController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyCarListController.h"
#import "CZJMyCarListCell.h"
#import "UIImageView+WebCache.h"
#import "CZJBaseDataManager.h"
@interface CZJMyCarListController ()
<
UITableViewDataSource,
UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CZJMyCarListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getCarListFromServer];
    // Do any additional setup after loading the view.
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.tableFooterView = [[UIView alloc]init];
    UINib* nib = [UINib nibWithNibName:@"CZJMyCarListCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:@"CZJMyCarListCell"];
    self.myTableView.hidden = YES;
}

- (void)getCarListFromServer
{
    [CZJBaseDataInstance getMyCarList:nil Success:^(id json) {
        self.myTableView.hidden = NO;
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self.myTableView reloadData];
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCarListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyCarListCell" forIndexPath:indexPath];
    [cell.brandImg sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil];
    cell.carNameLabel.text = @"奔驰迈巴赫";
    cell.carModelLabel.text = @"W12缸顶级";
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

@end
