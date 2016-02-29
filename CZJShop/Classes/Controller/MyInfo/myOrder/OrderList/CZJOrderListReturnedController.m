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
#import "CZJMyOrderDetailController.h"

@interface CZJOrderListReturnedController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    NSArray* returnedOrderListAry;
    NSString* statestr;
    CZJReturnedOrderListForm* returnedGoodsForm;
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
    NSString* api;
    NSDictionary* params;
    if (CZJReturnListTypeReturnable == self.returnListType)
    {
        api = kCZJServerAPIGetReturnableOrderList;
        params = @{@"orderNo":self.orderNo};
    }
    else
    {
        api = kCZJServerAPIGetReturnedOrderList;
    }
    
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        returnedOrderListAry = [CZJReturnedOrderListForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        [self.myTableView reloadData];
    } andServerAPI:api];

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
    
    if (CZJReturnListTypeReturnable == self.returnListType)
    {
        cell.returnStateLabel.hidden = YES;
    }
    if (CZJReturnListTypeReturned == self.returnListType)
    {
        cell.returnBtn.hidden = YES;
        switch ([form.returnStatus integerValue]) {
            case 1:
                statestr = @"等待卖家同意";
                break;
            case 2:
                statestr = @"卖家已同意，请寄回商品";
                break;
            case 3:
                statestr = @"等待卖家收货";
                break;
            case 4:
                statestr = @"退换货成功";
                break;
                
            default:
                break;
        }
        cell.returnStateLabel.text = statestr;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 109;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    returnedGoodsForm = (CZJReturnedOrderListForm*)returnedOrderListAry[indexPath.row];
    [self performSegueWithIdentifier:@"segueToReturnedOrderDetail" sender:returnedGoodsForm];
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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CZJMyOrderDetailController* orderDetailVC = segue.destinationViewController;
    orderDetailVC.navigationItem.title = @"退货订单详情";
    orderDetailVC.returnedGoodsForm = (CZJReturnedOrderListForm*)sender;
    orderDetailVC.orderDetailType = CZJOrderDetailTypeReturned;
    orderDetailVC.stageStr = statestr;
}


@end
