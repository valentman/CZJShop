//
//  CZJMyMessageCenterController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/21/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyMessageCenterController.h"
#import "CZJBaseDataManager.h"
#import "CZJMessageManager.h"
#import "CZJMyMessageCenterCell.h"
#import "CZJButtomView.h"
#import "CZJMyOrderDetailController.h"

@interface CZJMyMessageCenterController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    BOOL isEdit;
    NSMutableArray* messageInfoAry;
    CZJButtomView* buttomView;
}
@property (strong, nonatomic)UITableView* myTableView;
@property (weak, nonatomic) IBOutlet CZJButton *serviceInfoBtn;
@end

@implementation CZJMyMessageCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
    [self getMessageInfosFromServer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getMessageInfosFromServer) name:kCZJNotifiGetNewNotify object:nil];;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kCZJNotifiGetNewNotify object:nil];
}

- (void)initDatas
{
    messageInfoAry = [NSMutableArray array];
}

- (void)initViews
{
    isEdit = NO;
    [CZJUtils customizeNavigationBarForTarget:self];
    //右按钮
    UIBarButtonItem* rightItem2 = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = rightItem2;
    [self.navigationItem.rightBarButtonItem setTintColor:BLACKCOLOR];
    
    //消息中心表格视图
    CGRect tableRect = CGRectMake(0, 64 + 60, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64 - 60);
    self.myTableView = [[UITableView alloc]initWithFrame:tableRect style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = YES;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJMyMessageCenterCell"
                         ];
    
    for (id cells in nibArys)
    {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    [self.serviceInfoBtn setBadgeNum:-1];
    [self.serviceInfoBtn setBadgeLabelPosition:CGPointMake(self.serviceInfoBtn.size.width*1.1, 0)];
    
    
    //底部标记栏
    buttomView = (CZJButtomView*)[CZJUtils getXibViewByName:@"CZJButtomView"];
    [buttomView setSize:CGSizeMake(PJ_SCREEN_WIDTH, 60)];
    [buttomView setPosition:CGPointMake(0, PJ_SCREEN_HEIGHT) atAnchorPoint:CGPointZero];
    [self.view addSubview:buttomView];
    [buttomView.allChooseBtn addTarget:self action:@selector(allChooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttomView.buttonOne addTarget:self action:@selector(markReadedAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttomView.buttonTwo addTarget:self action:@selector(deleteMessageAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)edit:(id)sender
{
    isEdit = !isEdit;
    if (isEdit)
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        [UIView animateWithDuration:0.3 animations:^{
            [buttomView setPosition:CGPointMake(0, PJ_SCREEN_HEIGHT - 60) atAnchorPoint:CGPointZero];
            [self.myTableView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64 - 60 - 60)];
        }];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        [UIView animateWithDuration:0.3 animations:^{
            [buttomView setPosition:CGPointMake(0, PJ_SCREEN_HEIGHT) atAnchorPoint:CGPointZero];
            [self.myTableView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64 - 60)];
        }];
    }
    [self.myTableView reloadData];
}

- (void)getMessageInfosFromServer
{
    BACK(^{
        [CZJMessageInstance readMessageFromPlist];
        MAIN(^{
            messageInfoAry = [CZJMessageInstance.messages mutableCopy];
            if (messageInfoAry.count > 0)
            {
                buttomView.allChooseBtn.selected = NO;
                buttomView.allChooseBtn.enabled = YES;
                buttomView.buttonOne.enabled = YES;
                buttomView.buttonTwo.enabled = YES;
                [buttomView.buttonOne setBackgroundColor:CZJGREENCOLOR];
                [buttomView.buttonTwo setBackgroundColor:CZJREDCOLOR];
            }
            [self.myTableView reloadData];
        });
    });
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
    NSInteger count = messageInfoAry.count;
    DLog(@"count:%ld",count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNotificationForm* notifyForm = messageInfoAry[indexPath.row];
    CZJMyMessageCenterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyMessageCenterCell" forIndexPath:indexPath];
    CGSize timeSize = [CZJUtils calculateStringSizeWithString:notifyForm.time Font:cell.notifyTimeLabel.font Width:280];
    CGSize contentSize = [CZJUtils calculateStringSizeWithString:notifyForm.msg Font:cell.notifyContentLabel.font Width:PJ_SCREEN_WIDTH - 55];
    cell.storeNameWidth.constant = PJ_SCREEN_WIDTH - 25 - 10 - 15 - timeSize.width;
    cell.notifyTimeLabelWidth.constant = timeSize.width;
    cell.notifyContentHeight.constant = contentSize.height > 20 ? 40 : 20;
    cell.storeNameLabel.text = notifyForm.storeName;
    cell.notifyTimeLabel.text = notifyForm.time;
    cell.notifyContentLabel.text = notifyForm.msg;
    cell.dotLabel.hidden = notifyForm.isRead || isEdit;
    cell.selectBtn.hidden = !isEdit;
    cell.selectBtn.selected = notifyForm.isSelected;
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(notifyCellChoose:) forControlEvents:UIControlEventTouchUpInside];
    cell.separatorInset = IndentCellSeparator(10);
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNotificationForm* notifyForm = messageInfoAry[indexPath.row];
    CGSize contentSize = [CZJUtils calculateStringSizeWithString:notifyForm.msg Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 55];
    return 80 + (contentSize.height > 20 ? 20 : 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNotificationForm* notifyForm = messageInfoAry[indexPath.row];
    if (!notifyForm.isRead)
    {
        notifyForm.isRead = YES;
        [CZJMessageInstance setMessages:messageInfoAry];
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
        [self.myTableView reloadData];
    }
    if (4 == [notifyForm.type integerValue])
    {
        CZJMyOrderDetailController* orderDetail = (CZJMyOrderDetailController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"orderDetailSBID"];
        orderDetail.orderNo = notifyForm.orderNo;
        orderDetail.orderDetailType = CZJOrderDetailTypeGeneral;
        [self.navigationController pushViewController:orderDetail animated:YES];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 0;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEdit)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CZJNotificationForm* notifyForm = messageInfoAry[indexPath.row];
        [messageInfoAry removeObject:notifyForm];
        [CZJUtils tipWithText:@"删除成功" andView:nil];
        [CZJMessageInstance setMessages:messageInfoAry];
        [self.myTableView reloadData];
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


#pragma mark - 按钮点击事件
- (void)notifyCellChoose:(UIButton*)sender
{
    sender.selected = !sender.selected;
    CZJNotificationForm* notifyForm = messageInfoAry[sender.tag];
    notifyForm.isSelected = sender.selected;
    
    BOOL isallchoosed = YES;
    for (CZJNotificationForm* notifyForm2 in messageInfoAry)
    {
        if (!notifyForm2.isSelected)
        {
            isallchoosed = NO;
            break;
        }
    }
    buttomView.allChooseBtn.selected = isallchoosed;
}

- (void)allChooseAction:(UIButton*)sender
{
    sender.selected = !sender.selected;
    for (CZJNotificationForm* notifyForm in messageInfoAry)
    {
        notifyForm.isSelected = sender.selected;
    }
    [self.myTableView reloadData];
}

- (void)markReadedAction:(UIButton*)sender
{
    BOOL isSelected = NO;
    for (CZJNotificationForm* notifyForm in messageInfoAry)
    {
        if (notifyForm.isSelected)
        {
            isSelected = YES;
            notifyForm.isRead = YES;
        }
    }
    if (isSelected)
    {
        [self.myTableView reloadData];
        [CZJMessageInstance setMessages:messageInfoAry];
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
        [CZJUtils tipWithText:@"标记成功" andView:nil];
    }
    else
    {
        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
    }
}

- (void)deleteMessageAction:(UIButton*)sender
{
    BOOL isSelected = NO;
    NSMutableArray* tmpAry = [NSMutableArray array];
    for (CZJNotificationForm* notifyForm in messageInfoAry)
    {
        if (notifyForm.isSelected)
        {
            isSelected = YES;
            [tmpAry addObject:notifyForm];
        }
    }
    
    if (isSelected)
    {
        [CZJUtils tipWithText:@"删除成功" andView:nil];
        [messageInfoAry removeObjectsInArray:tmpAry];
        [CZJMessageInstance setMessages:messageInfoAry];
        if (messageInfoAry.count == 0)
        {
            buttomView.allChooseBtn.selected = NO;
            buttomView.allChooseBtn.enabled = NO;
            buttomView.buttonOne.enabled = NO;
            buttomView.buttonTwo.enabled = NO;
            [buttomView.buttonOne setBackgroundColor:CZJGRAYCOLOR];
            [buttomView.buttonTwo setBackgroundColor:CZJGRAYCOLOR];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
        [self.myTableView reloadData];
    }
    else
    {
        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
    }
}


@end
