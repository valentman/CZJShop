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
#import "CZJBaseDataManager.h"

@implementation CZJLogisticsForm
+ (NSDictionary*)objectClassInArray
{
    return @{@"items" : @"CZJLogisticsGoodItemForm"};
}
@end

@implementation CZJLogisticsGoodItemForm
@end

@interface CZJOrderLogisticsController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* logisticInfoAry;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation CZJOrderLogisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getLogisticInfoFromServer];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"物流信息";
    
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, 10)];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CLEARCOLOR;
    self.view.backgroundColor = CZJNAVIBARGRAYBG;
    NSArray* nibArys = @[@"CZJOrderLogisticsInfoCell",
                         @"CZJOrderLogisticsCompCell"
                         ];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
}

- (void)getLogisticInfoFromServer
{
    NSDictionary* params = @{@"orderNo":_orderNo};
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        NSArray* tmp = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        logisticInfoAry = [CZJLogisticsForm objectArrayWithKeyValuesArray:tmp];
        [self.myTableView reloadData];
    } andServerAPI:kCZJServerAPIGET_LOGISTICSINFO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //动态
    return logisticInfoAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJLogisticsForm* logisticsForm = logisticInfoAry[indexPath.section];
    if (0 == indexPath.row)
    {
        CZJOrderLogisticsInfoCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"CZJOrderLogisticsInfoCell" forIndexPath:indexPath];
        [cell.goodImg sd_setImageWithURL:nil placeholderImage:DefaultPlaceHolderImage];
        cell.logisticsLabel.text = logisticsForm.expressName;
        NSMutableArray* goodnameAry = [NSMutableArray array];
        for (CZJLogisticsGoodItemForm* itemForm in logisticsForm.items)
        {
            [goodnameAry addObject:itemForm.itemName];
        }
        cell.goodNameLabel.text = [goodnameAry componentsJoinedByString:@";"];
        cell.separatorInset = UIEdgeInsetsMake(109, 20, 0, 20);
        return cell;
    }
    if (1 == indexPath.row)
    {
        CZJOrderLogisticsCompCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"CZJOrderLogisticsCompCell" forIndexPath:indexPath];
        cell.logisticsNoLabel.text = logisticsForm.expressNo;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 109;
    }
    if (1 == indexPath.row)
    {
        return 61;
    }
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
