//
//  CZJOrderBuildingController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderBuildingController.h"
#import "CZJOrderBuilderCell.h"
#import "CZJOrderBuildCarCell.h"
#import "CZJOrderBuildingImagesCell.h"

@interface CZJOrderBuildingController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CZJOrderBuildingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"正在施工";
    
    NSArray* nibArys = @[@"CZJOrderBuilderCell",
                         @"CZJOrderBuildCarCell",
                         @"CZJOrderBuildingImagesCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (2 == section)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        CZJOrderBuildCarCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildCarCell" forIndexPath:indexPath];
        return cell;
    }
    if (1 == indexPath.section)
    {
        CZJOrderBuilderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuilderCell" forIndexPath:indexPath];
        return cell;
    }
    if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderBuildingImagesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderBuildingImagesCell" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            return cell;
        }
        
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return 82;
    }
    if (1 == indexPath.section)
    {
        return 167;
    }
    if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        if (1 == indexPath.row)
        {
            //动态调整的
            return 100;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section)
    {
        return 10;
    }
    return 0;
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
