//
//  CZJChatListController.m
//  CZJShop
//
//  Created by Joe.Pen on 5/6/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChatListController.h"
#import "CZJButtomView.h"
#import "CZJChatViewCell.h"
#import "CZJChatViewController.h"
#import "CZJConversation.h"

@interface CZJChatListController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    BOOL isEdit;
    CZJButtomView* buttomView;
    NSMutableArray* conversationAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initChatListViews];
    [self getChatConversations];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
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
    
    NSArray* nibArys = @[@"CZJChatViewCell"
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
    
    conversationAry = [NSMutableArray array];

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
    NSArray* tmpConversations = [[EMClient sharedClient].chatManager getAllConversations];
    for (int i = 0; i < tmpConversations.count; i++)
    {
        CZJConversation* conversation = [[CZJConversation alloc]init];
        conversation.emConversation = tmpConversations[i];
        conversation.isSelected = NO;
        [conversationAry addObject:conversation];
    }
    [self.myTableView reloadData];
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
    return conversationAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJConversation* conversation = conversationAry[indexPath.row];
    EMConversation* emConversation = conversation.emConversation;
    NSDictionary* extDict = emConversation.latestMessage.ext;
    EaseMessageModel* model = [[EaseMessageModel alloc]initWithMessage:emConversation.latestMessage];
    CZJChatViewCell* chatCell = [tableView dequeueReusableCellWithIdentifier:@"CZJChatViewCell" forIndexPath:indexPath];
    chatCell.viewLeading.constant = isEdit? 40 : 0;
    [chatCell.headPic sd_setImageWithURL:[NSURL URLWithString:[extDict valueForKey:@"storeImg"]] placeholderImage:IMAGENAMED(@"personal_icon_head")];
    chatCell.nameLabel.text = [extDict valueForKey:@"storeName"];
    
    chatCell.timeLabel.text = [CZJUtils getChatDatetime:emConversation.latestMessage.timestamp];
    chatCell.contentLabel.text = model.text;
    
    chatCell.selectBtn.hidden = !isEdit;
    chatCell.selectBtn.selected = conversation.isSelected;
    chatCell.selectBtn.tag = indexPath.row;
    [chatCell.selectBtn addTarget:self action:@selector(notifyCellChoose:) forControlEvents:UIControlEventTouchUpInside];
    return chatCell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJConversation* conversation = conversationAry[indexPath.row];
    EMConversation* emConversation = conversation.emConversation;
    NSDictionary* extDict = emConversation.latestMessage.ext;
    CZJChatViewController *chatController = [[CZJChatViewController alloc] initWithConversationChatter: emConversation.conversationId conversationType:EMConversationTypeChat];
    chatController.storeName = [extDict valueForKey:@"storeName"];
    chatController.storeImg = [extDict valueForKey:@"storeImg"];
    chatController.storeId = [extDict valueForKey:@"storeId"];

    [self.navigationController pushViewController:chatController animated:YES];
}


- (void)notifyCellChoose:(UIButton*)sender
{
    sender.selected = !sender.selected;
    CZJConversation* conversation = conversationAry[sender.tag];
    conversation.isSelected = sender.selected;
    
    BOOL isallchoosed = YES;
    for (CZJConversation* conver in conversationAry)
    {
        if (!conver.isSelected)
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
    for (CZJConversation* conver in conversationAry)
    {
        conver.isSelected = sender.selected;
    }
    [self.myTableView reloadData];
}

- (void)markReadedAction:(UIButton*)sender
{
    BOOL isSelected = NO;
//    for (CZJConversation* conver in conversationAry)
//    {
//        if (conver.isSelected)
//        {
//            isSelected = YES;
//            
//        }
//    }
//    if (isSelected)
//    {
//        [self.myTableView reloadData];
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
//    for (CZJConversation* conver in conversationAry)
//    {
//        if (conver.isSelected)
//        {
//            isSelected = YES;
//            [tmpAry addObject:conver];
//        }
//    }
    
//    if (isSelected)
//    {
//        [CZJUtils tipWithText:@"删除成功" andView:nil];
//        [conversationAry removeObjectsInArray:tmpAry];
//        [[EMClient sharedClient].chatManager deleteConversations:tmpAry deleteMessages:YES];
//        if (conversationAry.count == 0)
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