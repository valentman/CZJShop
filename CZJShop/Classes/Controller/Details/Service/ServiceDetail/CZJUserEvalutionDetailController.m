//
//  CZJUserEvalutionDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJUserEvalutionDetailController.h"
#import "CZJBaseDataManager.h"
#import "CZJEvalutionDetailCell.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJEvalutionHeaderCell.h"
#import "UIImageView+WebCache.h"
#import "PullTableView.h"

@interface CZJUserEvalutionDetailController ()
<
PullTableViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UITextViewDelegate
>
{
    NSMutableArray* userEvalutionReplys;
    CZJHomeGetDataFromServerType getDataTypeIsFresh;
}
@property (nonatomic, assign)int page;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet PullTableView *myTableView;

- (IBAction)commitEvalutionAction:(id)sender;
@end

@implementation CZJUserEvalutionDetailController
@synthesize textView = _textView;
@synthesize inputView = _inputView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)getReplyDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        userEvalutionReplys = [[CZJBaseDataInstance detailsForm] userEvalutionReplyForms];
        [self.myTableView reloadData];
        
    };
    [CZJBaseDataInstance loadUserEvalutionReplys:nil
                                            type:getDataTypeIsFresh
                                         Success:successBlock
                                            fail:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    getDataTypeIsFresh = CZJHomeGetDataFromServerTypeOne;
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.1f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    getDataTypeIsFresh = CZJHomeGetDataFromServerTypeTwo;
    [self performSelector:@selector(loadMoreToTable) withObject:nil afterDelay:0.1f];
    
}

/**
 *  @brief 刷新数据表
 *
 */
- (void)refreshTable
{
    self.page=1;
    [self getReplyDataFromServer];
}

/**
 *  @brief 载入更多
 *
 */
- (void)loadMoreToTable
{
    self.page++;
    [self getReplyDataFromServer];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 3;
    }
    if (1 == section) {
        if (userEvalutionReplys.count > 0) {
            return userEvalutionReplys.count + 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //当前回复内容
    if (indexPath.section == 0)
    {
        CZJEvalutionsForm* form = self.evalutionForm;
        if (indexPath.row == 0)
        {
            CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCellHead"];
            if (!cell)
            {
                cell = [[CZJEvalutionDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CZJEvalutionDetailCellHead"];
            }
            [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:form.evalHead] placeholderImage:nil];
            cell.evalWriterName.text = form.evalName;
            cell.evalWriteTime.text = form.evalTime;
            return cell;
        }
        if (indexPath.row == 1)
        {
            CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell"];
            if (!cell)
            {
                cell = [[CZJEvalutionDescCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CZJEvalutionDescCell"];
            }
            [cell setStar:form.evalStar];
            cell.evalContent.text = form.evalDesc;
            cell.evalTime.text = nil;
            cell.evalWriter.text = nil;
            int count = form.imgs.count;
            
            CGRect imagerect = cell.addtionnalImage.frame;
            for (int i = 0; i<count; i++)
            {
                UIImageView* image = [[UIImageView alloc]init];
                [image sd_setImageWithURL:[NSURL URLWithString:form.imgs[i]] placeholderImage:nil];
                
                int divide = 4;
                // 列数
                int column = i%divide;
                // 行数
                int row = i/divide;
                DLog(@"row:%d, column:%d", row, column);
                // 很据列数和行数算出x、y
                int childX = column * imagerect.size.width;
                int childY = row * imagerect.size.height;
                image.frame = CGRectMake(childX , childY, imagerect.size.width, imagerect.size.height);
                [cell addSubview:image];
            }
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell"];
            if (!cell)
            {
                cell = [[CZJEvalutionFooterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CZJEvalutionFooterCell"];
            }
            [cell setVisibleView:kEvalDetailView];
            cell.serviceName.text = form.purchaseItem;
            cell.serviceTime.text = form.purchaseTime;
            cell.form = form;
            return cell;
        }
    }
    
    //评论回复内容
    if (indexPath.section == 1)
    {
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellReplyHead"];
            if (!cell)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellReplyHead"];
                NSString* replystr = [NSString stringWithFormat:@"回复(%ld)",userEvalutionReplys.count];
                cell.textLabel.text = replystr;
            }
        }
        else
        {
            CZJEvalutionReplyForm* form = (CZJEvalutionReplyForm*)userEvalutionReplys[indexPath.row];
            CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCell"];
            if (!cell)
            {
                cell = [[CZJEvalutionDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CZJEvalutionDetailCell"];
            }
            [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil];
            cell.evalWriterName.text = form.replyName;
            cell.evalWriteTime.text = form.replyTime;
            cell.replyContent.text = form.replyDesc;
        }
        
    }
    return nil;
}


#pragma mark- UITextViewDelegate
//将要开始编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

//将要结束编辑
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

//开始编辑
//(TextView) 当键盘开始输入前。时行计算与动画加载
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"gegin animation");
//    sendMsgTextView =textView;
//    resultCommunityTableview.frame = CGRectMake(0, 36, 320, 150);
    //动画加载
    [self beginMoveUpAnimation:0.0 ];
}

//结束编辑
//输入结束时调用动画（把按键。背景。输入框都移下去）
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self endEditAnimation];
    //释放
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//控制输入文字的长度和内容，可通调用以下代理方法实现
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    resultCommunityTableview.frame = CGRectMake(0, 36, 320, 376);
    if (range.location>=100)
    {
        //控制输入文本的长度
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        //禁止输入换行
        [textView resignFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }

}

//有时候我们要控件自适应输入的文本的内容的高度，只要在textViewDidChange的代理方法中加入调整控件大小的代理即可
- (void)textViewDidChange:(UITextView *)textView{
    //计算文本的高度
    CGSize constraintSize;
    constraintSize.width = textView.frame.size.width-16;
    constraintSize.height = MAXFLOAT;
    CGSize sizeFrame =[textView.text sizeWithFont:textView.font
                                constrainedToSize:constraintSize
                                    lineBreakMode:UILineBreakModeWordWrap];
    //重新调整textView的高度
    textView.frame = CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,sizeFrame.height+5);
}

//焦点发生改变
//判断当前输入法
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"wewe:%@",[[UITextInputMode currentInputMode] primaryLanguage]);
    /*
     if ([[UITextInputMode currentInputMode] primaryLanguage] == @"en-US") {
     NSLog(@"en-US");
     }
     else
     {
     NSLog(@"zh-hans");
     }
     */
}

- (IBAction)commitEvalutionAction:(id)sender {
    [self.textView resignFirstResponder];
    //发送信息到服务器，再获取数据返回刷新
    
}


//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"hight_hitht:%f",kbSize.height);
    int keyboardhight;
    if(kbSize.height == 216)
    {
        keyboardhight = 0;
    }
    else
    {
        keyboardhight = 36;   //252 - 216 系统键盘的两个不同高度
    }
    //输入框位置动画加载
    [self beginMoveUpAnimation:keyboardhight];
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //do something
}

- (void)beginMoveUpAnimation:(int)height
{
    
}

- (void)endEditAnimation
{
    
}

@end
