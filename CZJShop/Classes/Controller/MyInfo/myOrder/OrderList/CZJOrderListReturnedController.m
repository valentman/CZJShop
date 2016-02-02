//
//  CZJOrderListReturnedController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/30/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListReturnedController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderForm.h"
#import "CZJOrderReturnedListCell.h"

@interface CZJOrderListReturnedController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    NSArray* returnedOrderListAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderListReturnedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getReturnedOrderListFromServer];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"退换货";
    
    
    //创建TableView，注册Cell
   
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderReturnedListCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getReturnedOrderListFromServer
{
    [CZJBaseDataInstance getReturnedOrderList:nil Success:^(id json) {
        returnedOrderListAry = [CZJReturnedOrderListForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return returnedOrderListAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJReturnedOrderListForm* form = (CZJReturnedOrderListForm*)returnedOrderListAry[indexPath.row];
    CZJOrderReturnedListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderReturnedListCell" forIndexPath:indexPath];
    cell.goodNameLabel.text = form.itemName;
    cell.goodModelLabel.text = form.itemSku;
    cell.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",form.currentPrice];
    [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:IMAGENAMED(@"")];
    NSString* statestr = @"卖家已同意，请寄回商品";
    if (1 == [form.returnStatus integerValue] )
    {
        statestr = @"卖家已同意，请寄回商品";
    }
    cell.returnStateLabel.text = statestr;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 109;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
