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
#import "CZJCommitReturnController.h"

@interface CZJOrderListReturnedController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    NSMutableArray* returnedOrderListAry;
    NSString* statestr;
    CZJReturnedOrderListForm* returnedGoodsForm;
    
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderListReturnedController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initViews];
    [self getReturnedOrderListFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getReturnedOrderListFromServer) name:kCZJNotifiRefreshReturnOrderlist object:nil];
}

- (void)removeOrderlistControllerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCZJNotifiRefreshReturnOrderlist object:nil];
}


- (void)initMyDatas
{
    returnedOrderListAry = [NSMutableArray array];
    page = 0;
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
    
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weak getReturnedOrderListFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
}

- (void)getReturnedOrderListFromServer
{
    NSString* api;
    NSMutableDictionary* params = [@{@"page" : @(page)}mutableCopy];
    if (CZJReturnListTypeReturnable == self.returnListType)
    {
        api = kCZJServerAPIGetReturnableOrderList;
        [params setValue:self.orderNo forKey:@"orderNo"];
    }
    else
    {
        api = kCZJServerAPIGetReturnedOrderList;
    }
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [returnedOrderListAry addObjectsFromArray: [CZJReturnedOrderListForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 20)
            {
                [refreshFooter noticeNoMoreData];
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
            }
        }
        else
        {
            returnedOrderListAry = [[CZJReturnedOrderListForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
            if (returnedOrderListAry.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        
        if (returnedOrderListAry.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有浏览记录/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (returnedOrderListAry.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = YES;
        }
    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getReturnedOrderListFromServer];
        }];
    } andServerAPI:api];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        [cell.returnBtn setTag:indexPath.row];
        [cell.returnBtn addTarget:self action:@selector(segueToReturn:) forControlEvents:UIControlEventTouchUpInside];
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
    if (_returnListType == CZJReturnListTypeReturned)
    {
        returnedGoodsForm = (CZJReturnedOrderListForm*)returnedOrderListAry[indexPath.row];
        [self performSegueWithIdentifier:@"segueToReturnedOrderDetail" sender:returnedGoodsForm];
    }
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


- (void)segueToReturn:(UIButton*)sender
{
    returnedGoodsForm = (CZJReturnedOrderListForm*)returnedOrderListAry[sender.tag];
    [self performSegueWithIdentifier:@"segueToCommitReturn" sender:returnedGoodsForm];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToReturnedOrderDetail"])
    {
        CZJMyOrderDetailController* orderDetailVC = segue.destinationViewController;
        orderDetailVC.navigationItem.title = @"退货订单详情";
        orderDetailVC.returnedGoodsForm = (CZJReturnedOrderListForm*)sender;
        orderDetailVC.orderDetailType = CZJOrderDetailTypeReturned;
        orderDetailVC.stageStr = statestr;
    }
    if ([segue.identifier isEqualToString:@"segueToCommitReturn"])
    {
        CZJCommitReturnController* returnControlf = segue.destinationViewController;
        returnControlf.returnedGoodsForm = (CZJReturnedOrderListForm*)sender;
    }

}


@end
