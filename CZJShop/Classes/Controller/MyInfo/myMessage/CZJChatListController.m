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
#import "CZJBaseDataManager.h"

#define Duration 0.35

@interface CZJChatListController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    BOOL isEdit;
    __block CZJButtomView* buttomView;
    NSMutableArray* conversationAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initChatListViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getChatConversations];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)initChatListViews
{
    isEdit = NO;
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"客服消息";;
    
    
    //右按钮
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(PJ_SCREEN_WIDTH - 100 , 0 , 100 , 44 );
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitle:@"取消" forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    [rightBtn setTag:2999];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    [self.naviBarView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    
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
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    isEdit = !isEdit;
    
    if (conversationAry.count <= 0)
        return;
    
    [self setButtomViewShowAnimation:isEdit];
    [self.myTableView reloadData];
}


- (void)getChatConversations
{
    [conversationAry removeAllObjects];
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
    if ([emConversation.conversationId isEqualToString:CZJBaseDataInstance.userInfoForm.kefuId])
    {
        [extDict setValue:CZJBaseDataInstance.userInfoForm.kefuHead forKey:@"storeImg"];
        [extDict setValue:@"车之健客服" forKey:@"storeName"];
    }
    EaseMessageModel* model = [[EaseMessageModel alloc]initWithMessage:emConversation.latestMessage];
    CZJChatViewCell* chatCell = [tableView dequeueReusableCellWithIdentifier:@"CZJChatViewCell" forIndexPath:indexPath];
    [chatCell.unreadBtn setBadgeNum:[emConversation unreadMessagesCount]];
    
    //约束也能做动画
    [chatCell layoutIfNeeded];
    [UIView animateWithDuration:Duration animations:^{
        chatCell.viewLeading.constant = isEdit? 40 : 0;
        [chatCell layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    
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
    if (!isEdit)
    {
        CZJConversation* conversation = conversationAry[indexPath.row];
        EMConversation* emConversation = conversation.emConversation;
        NSDictionary* extDict = emConversation.latestMessage.ext;
        if ([emConversation.conversationId isEqualToString:CZJBaseDataInstance.userInfoForm.kefuId])
        {
            [extDict setValue:CZJBaseDataInstance.userInfoForm.kefuHead forKey:@"storeImg"];
            [extDict setValue:@"车之健客服" forKey:@"storeName"];
        }
        CZJChatViewController *chatController = [[CZJChatViewController alloc] initWithConversationChatter: emConversation.conversationId conversationType:EMConversationTypeChat];
        chatController.storeName = [extDict valueForKey:@"storeName"];
        chatController.storeImg = [extDict valueForKey:@"storeImg"];
        chatController.storeId = [extDict valueForKey:@"storeId"];
        
        [self.navigationController pushViewController:chatController animated:YES];
    }
    else
    {
        CZJChatViewCell* chatCell = [tableView cellForRowAtIndexPath:indexPath];
        [self notifyCellChoose:chatCell.selectBtn];
    }

}


- (void)notifyCellChoose:(UIButton*)sender
{
    sender.selected = !sender.selected;
    CZJConversation* conversation = conversationAry[sender.tag];
    conversation.isSelected = sender.selected;
    
    BOOL isallchoosed = YES;
    int count = 0;
    for (CZJConversation* conver in conversationAry)
    {
        if (!conver.isSelected)
        {
            isallchoosed = NO;
        }
        else
        {
            count++;
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
    for (CZJConversation* conver in conversationAry)
    {
        if (conver.isSelected)
        {
            isSelected = YES;
        }
    }
    if (isSelected)
    {
        [self.myTableView reloadData];
        for (CZJConversation* conver in conversationAry)
        {
            if (conver.isSelected)
            {
                [conver.emConversation markAllMessagesAsRead];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
        [CZJUtils tipWithText:@"标记已读成功" andView:nil];
    }
    else
    {
        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
    }
}

- (void)deleteMessageAction:(UIButton*)sender
{
    __weak typeof(self) weakSelf = self;
    BOOL isSelected = NO;
    NSMutableArray* tmpAry = [NSMutableArray array];
    for (CZJConversation* conver in conversationAry)
    {
        if (conver.isSelected)
        {
            isSelected = YES;
            [tmpAry addObject:conver];
        }
    }
    
    if (isSelected)
    {
        NSString* alertStr = [NSString stringWithFormat:@"确认删除这%ld条消息记录吗?",tmpAry.count];
        [self showCZJAlertView:alertStr andConfirmHandler:^{
            [CZJUtils tipWithText:@"删除成功" andView:nil];
            [conversationAry removeObjectsInArray:tmpAry];
            if (conversationAry.count == 0)
            {
                [weakSelf setButtomViewShowAnimation:NO];
            }
            
            NSMutableArray* tmpAry2 = [NSMutableArray array];
            for (CZJConversation* conver in tmpAry)
            {
                [tmpAry2 addObject:conver.emConversation];
            }
            [[EMClient sharedClient].chatManager deleteConversations:tmpAry2 deleteMessages:YES];
            if (conversationAry.count == 0)
            {
                buttomView.allChooseBtn.selected = NO;
                buttomView.allChooseBtn.enabled = NO;
                buttomView.buttonOne.enabled = NO;
                buttomView.buttonTwo.enabled = NO;
                [buttomView.buttonOne setBackgroundColor:CZJGRAYCOLOR];
                [buttomView.buttonTwo setBackgroundColor:CZJGRAYCOLOR];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiRefreshMessageReadStatus object:nil];
            [weakSelf.myTableView reloadData];
            [weakSelf hideWindow];
        } andCancleHandler:nil];
    }
    else
    {
        [CZJUtils tipWithText:@"请选择消息记录" andView:nil];
    }
}

- (void)setButtomViewShowAnimation:(BOOL)_isShow
{
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint destPt = CGPointMake(0, _isShow? PJ_SCREEN_HEIGHT - 60 : PJ_SCREEN_HEIGHT);
        CGSize destSize = CGSizeMake(PJ_SCREEN_WIDTH, _isShow ? PJ_SCREEN_HEIGHT - 64 - 60 : PJ_SCREEN_HEIGHT - 64);
        [buttomView setPosition:destPt atAnchorPoint:CGPointZero];
        [self.myTableView setSize:destSize];
    }];
    
}
@end
