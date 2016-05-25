//
//  CZJMessageOrderController.m
//  CZJShop
//
//  Created by Joe.Pen on 5/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMessageOrderController.h"
#import "CZJOrderMessageCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMessageOrderController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* orderList;
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
}
@property (strong, nonatomic)UITableView* myTableView;
@property (assign, nonatomic) NSInteger page;
@end

@implementation CZJMessageOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getOrderListFromServer];
}

- (void)initViews
{
    orderList = [NSMutableArray array];
    self.page = 1;
    
    self.view.backgroundColor = WHITECOLOR;
    
    //创建TableView，注册Cell
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderMessageCell"];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        weak.page++;
        [weak getOrderListFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
    
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"发送订单信息";
}

- (void)getOrderListFromServer
{
    __weak typeof(self) weak = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.completionBlock = ^{
    };
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    
    [CZJBaseDataInstance getOrderList:@{@"page" : @(self.page),@"storeId" : (self.storeId == nil ? @"" : self.storeId)} Success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        DLog(@"orderList:%@",[[CZJUtils DataFromJson:json] valueForKey:@"msg"]);
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [orderList addObjectsFromArray: [CZJOrderListForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 10)
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
            orderList = [[CZJOrderListForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
            if (orderList.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        
        //========获取数据返回,刷新表格==========
        if (orderList.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"无可发送订单"];
        }
        else
        {
            self.myTableView.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getOrderListFromServer];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return orderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderListForm* orderListForm = orderList[indexPath.section];
    CZJOrderMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderMessageCell" forIndexPath:indexPath];
    [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:((CZJOrderGoodsForm*)orderListForm.items.firstObject).itemImg] placeholderImage:DefaultPlaceHolderSquare];
    cell.orderNoLabel.text = orderListForm.orderNo;
    cell.orderMoneyNumLabel.text = [NSString stringWithFormat:@"￥%@",orderListForm.orderMoney];
    cell.orderTimerLabel.text = orderListForm.createTime;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderListForm* orderListForm = orderList[indexPath.section];
    if ([self.delegate respondsToSelector:@selector(clickMessageOneOrder:)])
    {
        [self.delegate clickMessageOneOrder:orderListForm];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
