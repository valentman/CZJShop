//
//  CZJOrderLogisticsController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderLogisticsController.h"
#import "CZJOrderLogisticsCompCell.h"
#import "CZJOrderLogisticsInfoCell.h"

@interface CZJOrderLogisticsController ()

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation CZJOrderLogisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"物流信息";
    
    NSArray* nibArys = @[@"CZJOrderLogisticsInfoCell",
                         @"CZJOrderLogisticsCompCell"
                         ];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //动态
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        CZJOrderLogisticsInfoCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"CZJOrderLogisticsInfoCell" forIndexPath:indexPath];
        return cell;
    }
    if (1 == indexPath.row)
    {
        CZJOrderLogisticsCompCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"CZJOrderLogisticsCompCell" forIndexPath:indexPath];
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
@end
