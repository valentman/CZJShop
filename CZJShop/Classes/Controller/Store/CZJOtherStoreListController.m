//
//  CZJOtherStoreListController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOtherStoreListController.h"
#import "CZJNaviagtionBarView.h"
#import "CZJStoreCell.h"
#import "UIImageView+WebCache.h"
#import "CZJStoreForm.h"
#import "CZJBaseDataManager.h"
#import "CZJStoreDetailController.h"

@interface CZJOtherStoreListController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJNaviagtionBarViewDelegate
>
{
    NSMutableArray* _sortedStoreArys;
}
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *naviBarView;
@property (weak, nonatomic) IBOutlet UITableView *storeTableView;
@end

@implementation CZJOtherStoreListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sortedStoreArys = [NSMutableArray array];
    [self getOtherStoreListFromServer];
    [self dealWithTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getOtherStoreListFromServer
{
    NSDictionary* params = @{@"companyId" : self.companyId,@"storeId" : self.storeID};
    [CZJBaseDataInstance loadOtherStoreList:params success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpAry = [dict valueForKey:@"msg"];
        for (NSDictionary* nearbyData in tmpAry)
        {
            CZJNearbyStoreForm* form = [[CZJNearbyStoreForm alloc]initWithDictionary:nearbyData];
            [_sortedStoreArys addObject:form];
        }
        self.storeTableView.delegate = self;
        self.storeTableView.dataSource = self;
        [self.storeTableView reloadData];
    } fail:^{
        
    }];
}

- (void)dealWithTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.storeTableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib=[UINib nibWithNibName:@"CZJStoreCell" bundle:nil];
    [self.storeTableView registerNib:nib forCellReuseIdentifier:@"CZJStoreCell"];
    self.storeTableView.tableFooterView = [[UIView alloc]init];
    self.navigationController.navigationBarHidden = YES;
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    [self.naviBarView initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeGeneral].delegate = self;
    self.naviBarView.mainTitleLabel.text = @"其他分店";
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TICK;
    CZJStoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreCell" forIndexPath:indexPath];
    CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)_sortedStoreArys[indexPath.row];
    cell.storeName.text = storeForm.name;
    cell.dealCount.text = storeForm.purchaseCount;
    cell.storeDistance.text = storeForm.distance;
    cell.storeLocation.text = storeForm.addr;
    cell.feedbackRate.text = storeForm.star;
    [cell.storeCellImageView sd_setImageWithURL:[NSURL URLWithString:storeForm.homeImg] placeholderImage:nil];
    TOCK;
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_sortedStoreArys.count > 0)
    {
        return 1;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cout = _sortedStoreArys.count;
    return cout;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNearbyStoreForm* storeForm = (CZJNearbyStoreForm*)_sortedStoreArys[indexPath.row];
    CZJStoreDetailController* sdVC = (CZJStoreDetailController*)[CZJUtils getViewControllerFromStoryboard:@"Main" andVCName:@"storeDetailVC"];
    sdVC.storeId = storeForm.storeId;
    [self.navigationController pushViewController:sdVC animated:YES];
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
