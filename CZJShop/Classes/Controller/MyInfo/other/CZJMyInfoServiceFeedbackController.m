//
//  CZJMyInfoServiceFeedbackController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoServiceFeedbackController.h"
#import "CZJOrderCouponCell.h"
#import "CZJOrderForm.h"
#import "CZJChatViewController.h"
#import "CZJBaseDataManager.h"

@interface CZJMyInfoServiceFeedbackController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* cellArray;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CZJMyInfoServiceFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myTableView.scrollEnabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray* nibArys = @[@"CZJOrderCouponCell"];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    CZJOrderTypeForm* onlineService = [[CZJOrderTypeForm alloc]init];
    onlineService.orderTypeName = @"在线客服";
    onlineService.orderTypeImg = @"serve_icon_kefu";
    CZJOrderTypeForm* phoneAsk = [[CZJOrderTypeForm alloc]init];
    phoneAsk.orderTypeName = @"电话咨询";
    phoneAsk.orderTypeImg = @"serve_icon_call";
    CZJOrderTypeForm* feedback = [[CZJOrderTypeForm alloc]init];
    feedback.orderTypeName = @"意见反馈";
    feedback.orderTypeImg = @"my_icon_serve";
    CZJOrderTypeForm* zhibaoCard = [[CZJOrderTypeForm alloc]init];
    zhibaoCard.orderTypeName = @"质保卡查询";
    zhibaoCard.orderTypeImg = @"my_icon_zhibao";
    cellArray = @[onlineService,phoneAsk,feedback];
    
    [self.myTableView reloadData];
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnBack.hidden = YES;
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
    return cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJOrderTypeForm* form = (CZJOrderTypeForm*)cellArray[indexPath.row];
    CZJOrderCouponCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponCell" forIndexPath:indexPath];
    [cell.contentImg setImage:IMAGENAMED(form.orderTypeImg)];
    cell.contentNameLabel.text = form.orderTypeName;
    cell.contentNamelabelWidth.constant = 100;
    [cell.orderCouponScrollView removeFromSuperview];
    if (indexPath.row == cellArray.count - 1)
    {
        cell.separatorInset = HiddenCellSeparator;
    }
    
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        CZJChatViewController *chatController = [[CZJChatViewController alloc] initWithConversationChatter: CZJBaseDataInstance.userInfoForm.kefuId conversationType:EMConversationTypeChat];
        chatController.storeName = @"车之健客服";
        chatController.storeId = @"";
        chatController.storeImg = CZJBaseDataInstance.userInfoForm.kefuHead;
        [self.navigationController pushViewController:chatController animated:YES];
    }
    if (1 == indexPath.row)
    {
        [CZJUtils callHotLine:self.hotLine AndTarget:self.view];
    }
    if (2 == indexPath.row )
    {
        [self performSegueWithIdentifier:@"segueToOpinionFeedback" sender:self];
    }
    if (3 == indexPath.row)
    {
        CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
        webView.cur_url = [kCZJServerAddr stringByAppendingString:kCZJServerAPIZHIBAOCARD];
        [self.navigationController pushViewController:webView animated:YES];
    }

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


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
