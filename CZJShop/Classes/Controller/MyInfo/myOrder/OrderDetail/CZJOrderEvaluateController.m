//
//  CZJOrderEvaluateController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderEvaluateController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderEvaluateCell.h"
#import "CZJOrderEvalutateAllCell.h"
#import "CZJOrderForm.h"

@interface CZJOrderEvaluateController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* evaluateGoodsAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderEvaluateController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getEvalutatableOrderFromServer];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"发表评价";
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderEvaluateCell",
                         @"CZJOrderEvalutateAllCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getEvalutatableOrderFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getReturnableOrderList:params Success:^(id json) {
        evaluateGoodsAry = [CZJReturnedOrderListForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
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
    return evaluateGoodsAry.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 <= indexPath.section && indexPath.section < evaluateGoodsAry.count)
    {
        CZJReturnedOrderListForm* returnedListForm = (CZJReturnedOrderListForm*)evaluateGoodsAry[indexPath.section];
        CZJOrderEvaluateCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderEvaluateCell" forIndexPath:indexPath];
        [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:returnedListForm.itemImg] placeholderImage:IMAGENAMED(@"")];
        cell.goodsNameLabel.text = returnedListForm.itemName;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == evaluateGoodsAry.count)
    {
        CZJOrderEvalutateAllCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderEvalutateAllCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == evaluateGoodsAry.count + 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"clearCell"];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = CZJREDCOLOR;
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = SYSTEMFONT(15);
            [button addTarget:self action:@selector(addMyComment:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"发表评价" forState:UIControlStateNormal];
            button.layer.cornerRadius = 2.5;
            CGRect btnFrame = CGRectMake(50, 30, PJ_SCREEN_WIDTH - 100, 45);
            button.frame = btnFrame;
            cell.backgroundColor = RGB(245, 245, 245);
            [cell addSubview:button];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 <= indexPath.section && indexPath.section < evaluateGoodsAry.count)
    {
        return 307;
    }
    if (indexPath.section == evaluateGoodsAry.count)
    {
        return 159;
    }
    if (indexPath.section == evaluateGoodsAry.count + 1)
    {
        return 100;
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



- (void)addMyComment:(id)sender
{
    DLog(@"发表评价");
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
