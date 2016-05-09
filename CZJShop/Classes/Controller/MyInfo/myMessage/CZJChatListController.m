//
//  CZJChatListController.m
//  CZJShop
//
//  Created by Joe.Pen on 5/6/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChatListController.h"
#import "CZJButtomView.h"

@interface CZJChatListController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    BOOL isEdit;
    CZJButtomView* buttomView;
    NSArray* conversationAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initChatListViews];
    [self getChatConversations];
}

- (void)initChatListViews
{
    isEdit = NO;
    [CZJUtils customizeNavigationBarForTarget:self];
    self.title = @"客服消息";
    
    //右按钮
    UIBarButtonItem* rightItem2 = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = rightItem2;
    [self.navigationItem.rightBarButtonItem setTintColor:BLACKCOLOR];
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = YES;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCommentCell"
                         ];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
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
            [self.myTableView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64 - 60)];
        }];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        [UIView animateWithDuration:0.3 animations:^{
            [buttomView setPosition:CGPointMake(0, PJ_SCREEN_HEIGHT) atAnchorPoint:CGPointZero];
            [self.myTableView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64)];
        }];
    }
    [self.myTableView reloadData];
}


- (void)getChatConversations
{
    conversationAry = [[EMClient sharedClient].chatManager getAllConversations];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMConversation* conversation = conversationAry[indexPath.row];
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)allChooseAction:(UIButton*)sender
{
    sender.selected = !sender.selected;
//    for (CZJNotificationForm* notifyForm in messageInfoAry)
//    {
//        notifyForm.isSelected = sender.selected;
//    }
    [self.myTableView reloadData];
}

- (void)markReadedAction:(UIButton*)sender
{
    BOOL isSelected = NO;
//    for (CZJNotificationForm* notifyForm in messageInfoAry)
//    {
//        if (notifyForm.isSelected)
//        {
//            isSelected = YES;
//            notifyForm.isRead = YES;
//        }
//    }
//    if (isSelected)
//    {
//        [self.myTableView reloadData];
//        [CZJMessageInstance setMessages:messageInfoAry];
//        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
//        [CZJUtils tipWithText:@"标记成功" andView:nil];
//    }
//    else
//    {
//        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
//    }
}

- (void)deleteMessageAction:(UIButton*)sender
{
    BOOL isSelected = NO;
    NSMutableArray* tmpAry = [NSMutableArray array];
//    for (CZJNotificationForm* notifyForm in messageInfoAry)
//    {
//        if (notifyForm.isSelected)
//        {
//            isSelected = YES;
//            [tmpAry addObject:notifyForm];
//        }
//    }
//    
//    if (isSelected)
//    {
//        [CZJUtils tipWithText:@"删除成功" andView:nil];
//        [messageInfoAry removeObjectsInArray:tmpAry];
//        [CZJMessageInstance setMessages:messageInfoAry];
//        if (messageInfoAry.count == 0)
//        {
//            buttomView.allChooseBtn.selected = NO;
//            buttomView.allChooseBtn.enabled = NO;
//            buttomView.buttonOne.enabled = NO;
//            buttomView.buttonTwo.enabled = NO;
//            [buttomView.buttonOne setBackgroundColor:CZJGRAYCOLOR];
//            [buttomView.buttonTwo setBackgroundColor:CZJGRAYCOLOR];
//        }
//        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
//        [self.myTableView reloadData];
//    }
//    else
//    {
//        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
//    }
}


@end
