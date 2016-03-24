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
#import "CZJEvalutionDetailReplyCell.h"
#import "PullTableView.h"

@interface CZJUserEvalutionDetailController ()
<
PullTableViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UITextViewDelegate,
CZJNaviagtionBarViewDelegate
>
{
    NSMutableArray* userEvalutionReplys;
    CZJHomeGetDataFromServerType getDataTypeIsFresh;
    CGRect _destinateFrame;
    CGRect _originFrame;
    CGSize _inputViewSize;
}
@property (nonatomic, assign)int page;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet PullTableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *myNaviBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewLayoutHeight;

- (IBAction)commitEvalutionAction:(id)sender;
@end

@implementation CZJUserEvalutionDetailController
@synthesize textView = _textView;
@synthesize inputView = _inputView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _commitBtn.layer.cornerRadius = 5;
    _textView.layer.cornerRadius = 5;
    
    _textView.delegate = self;
    
    _originFrame = _inputView.frame;
    _inputViewSize = _originFrame.size;
    
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    CGRect viewBounds = CGRectMake(0, 0, mainViewBounds.size.width, 52);
    [self.myNaviBarView initWithFrame:viewBounds AndType:CZJNaviBarViewTypeDetail].delegate = self;
    [self.myNaviBarView setBackgroundColor:RGBA(239, 239, 239, 0)];
    self.myTableView.pullDelegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self.myTableView reloadData];
    //TableView初始化
    UINib *nib1=[UINib nibWithNibName:@"CZJEvalutionDetailCell" bundle:nil];
    UINib *nib2=[UINib nibWithNibName:@"CZJEvalutionDescCell" bundle:nil];
    UINib *nib3=[UINib nibWithNibName:@"CZJEvalutionFooterCell" bundle:nil];
    UINib *nib4=[UINib nibWithNibName:@"CZJEvalutionDetailReplyCell" bundle:nil];
    
    [self.myTableView registerNib:nib1 forCellReuseIdentifier:@"CZJEvalutionDetailCellHead"];
    [self.myTableView registerNib:nib2 forCellReuseIdentifier:@"CZJEvalutionDescCell"];
    [self.myTableView registerNib:nib3 forCellReuseIdentifier:@"CZJEvalutionFooterCell"];
    [self.myTableView registerNib:nib4 forCellReuseIdentifier:@"CZJEvalutionDetailReplyCell"];
    [self registerForKeyboardNotifications];
    [self getReplyDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_myNaviBarView refreshShopBadgeLabel];
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
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
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

- (void)refreshTable
{
    self.page=1;
    [self getReplyDataFromServer];
}

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
            CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCellHead" forIndexPath:indexPath];

            [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:form.evalHead] placeholderImage:DefaultPlaceHolderImage];
            cell.evalWriterName.text = form.evalName;
            cell.evalWriteTime.text = form.evalTime;
            return cell;
        }
        if (indexPath.row == 1)
        {
            CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
            cell.arrowNextImage.hidden = YES;
            [cell setStar:[form.evalStar intValue]];
            CGSize contenSize = [CZJUtils calculateStringSizeWithString:form.evalDesc Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40];
            cell.evalContentLayoutHeight.constant = contenSize.height;
            cell.evalContent.text = form.evalDesc;
            cell.evalTime.text = nil;
            cell.evalWriter.text = nil;
            NSInteger count = form.imgs.count;
            
//            CGRect imagerect = cell.addtionnalImage.frame;
//            for (int i = 0; i<count; i++)
//            {
//                UIImageView* image = [[UIImageView alloc]init];
//                [image sd_setImageWithURL:[NSURL URLWithString:form.imgs[i]] placeholderImage:DefaultPlaceHolderImage];
//                image.layer.cornerRadius = 2;
//                image.clipsToBounds = YES;
//                int divide = 4;
//                // 列数
//                int column = i%divide;
//                // 行数
//                int row = i/divide;
//                DLog(@"row:%d, column:%d", row, column);
//                // 很据列数和行数算出x、y
//                int childX = column * (imagerect.size.width + 10);
//                int childY = row * imagerect.size.height;
//                image.frame = CGRectMake(20 + childX , childY + contenSize.height + 40, imagerect.size.width, imagerect.size.height);
//                [cell addSubview:image];
//            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (2 == indexPath.row)
        {
            CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
            [cell setVisibleView:kEvalDetailView];
            cell.serviceName.text = form.purchaseItem;
            cell.serviceTime.text = form.purchaseTime;
            cell.form = form;
            cell.evalutionReplyBtn.hidden = YES;
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
                cell.textLabel.font = SYSTEMFONT(13);
            }
            return cell;
        }
        else
        {
            CZJEvalutionReplyForm* form = (CZJEvalutionReplyForm*)userEvalutionReplys[indexPath.row - 1];
            CZJEvalutionDetailReplyCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailReplyCell" forIndexPath:indexPath];
            NSString* replyContent = form.replyDesc;
            CGSize contentSize = [CZJUtils calculateStringSizeWithString:replyContent Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40];
            [cell.replyImage sd_setImageWithURL:[NSURL URLWithString:form.replyHead] placeholderImage:DefaultPlaceHolderImage];
            cell.replyNameLabel.text = form.replyName;
            cell.replyTimeLabel.text = form.replyTime;
            cell.replyContentLabel.text = replyContent;
            cell.replyContentLayoutHeight.constant = contentSize.height;
            return cell;
        }
        
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row) {
            return 46;
        }
        if (1 == indexPath.row) {
            //这里是动态改变的，暂时设一个固定值
            CGSize contenSize = [CZJUtils calculateStringSizeWithString:self.evalutionForm.evalDesc Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40];
            
            return contenSize.height + 40 + 10 + 80;
        }
        if (2 == indexPath.row)
        {
            return 64;
        }
    }
    else if (1==indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 46;
        }
        else
        {
            CZJEvalutionReplyForm* form = (CZJEvalutionReplyForm*)userEvalutionReplys[indexPath.row - 1];
            NSString* replyContent = form.replyDesc;
            CGSize contentSize = [CZJUtils calculateStringSizeWithString:replyContent Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40];
            return 70 + contentSize.height;
        }
    }
    return 0;
}

#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}


#pragma mark- UITextViewDelegate
//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    DLog(@"hight_hitht:%f",kbSize.height);
    //输入框位置动画加载
    [self beginMoveUpAnimation:kbSize.height];
}


//控制输入文字的长度和内容，可通调用以下代理方法实现
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DLog();
    //对于退格删除键开放限制
    if (text.length == 0) {
        return YES;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_INPUT) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_INPUT - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        //加入动态计算高度
        CGSize size = [self getStringRectInTextView:comcatstr InTextView:textView];
        CGRect frame = textView.frame;
        frame.size.height = size.height;
        
//        textView.frame = frame;
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          NSInteger steplen = substring.length;
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx = idx + steplen;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            
            //由于后面反回的是NO不触发didchange
//            [self refreshTextViewSize:textView];
            //既然是超出部分截取了，哪一定是最大限制了。
//            self.lbNums.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_INPUT];
        }
        return NO;
    }
}


//焦点发生改变
//判断当前输入法
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    DLog(@"wewe:%@",[[UITextInputMode currentInputMode] primaryLanguage]);
}


//有时候我们要控件自适应输入的文本的内容的高度，只要在textViewDidChange的代理方法中加入调整控件大小的代理即可
- (void)textViewDidChange:(UITextView *)textView{
    DLog();
    
    
//    //计算文本的高度
//    CGSize constraintSize;
//    constraintSize.width = textView.frame.size.width-16;
//    constraintSize.height = MAXFLOAT;
//    NSString* textStr = textView.text;
//    CGSize sizeFrame =[textStr sizeWithFont:textView.font
//                                constrainedToSize:constraintSize
//                                    lineBreakMode:UILineBreakModeWordWrap];
//    DLog(@"%f",sizeFrame.height);
////    CGSize sizeFrame =[CZJUtils calculateStringSizeWithString:textStr Font:SYSTEMFONT(13) Width:constraintSize.width];
//    //重新调整textView的高度
////    textView.frame = CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,sizeFrame.height+5);
//    [self refreshTextViewSize:textView];
//    
//    _inputView.frame = _destinateFrame;

    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_INPUT)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:MAX_INPUT];
        
        [textView setText:s];
    }
    
    
//    [self refreshTextViewSize:textView];
//
//    CGRect changeInputView = CGRectMake(_destinateFrame.origin.x, _destinateFrame.origin.y - (textView.frame.size.height + 20 - 55), _destinateFrame.size.width, textView.frame.size.height + 20);
////    _inputView.frame = changeInputView;
//    _inputView.center = CGPointMake( PJ_SCREEN_WIDTH/2, _destinateFrame.origin.y - (textView.frame.size.height + 20 - 55));
}



- (CGSize)getStringRectInTextView:(NSString *)string InTextView:(UITextView *)textView;
{
    DLog();
    //实际textView显示时我们设定的宽
    CGFloat contentWidth = CGRectGetWidth(textView.frame);
    //但事实上内容需要除去显示的边框值
    CGFloat broadWith    = (textView.contentInset.left + textView.contentInset.right
                            + textView.textContainerInset.left
                            + textView.textContainerInset.right
                            + textView.textContainer.lineFragmentPadding/*左边距*/
                            + textView.textContainer.lineFragmentPadding/*右边距*/);
    
    CGFloat broadHeight  = (textView.contentInset.top
                            + textView.contentInset.bottom
                            + textView.textContainerInset.top
                            + textView.textContainerInset.bottom);//+self.textview.textContainer.lineFragmentPadding/*top*//*+theTextView.textContainer.lineFragmentPadding*//*there is no bottom padding*/);
    
    //由于求的是普通字符串产生的Rect来适应textView的宽
    contentWidth -= broadWith;
    
    CGSize InSize = CGSizeMake(contentWidth, MAXFLOAT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = textView.textContainer.lineBreakMode;
    NSDictionary *dic = @{NSFontAttributeName:textView.font, NSParagraphStyleAttributeName:[paragraphStyle copy]};
    
    CGSize calculatedSize =  [string boundingRectWithSize:InSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    CGSize adjustedSize = CGSizeMake(ceilf(calculatedSize.width),calculatedSize.height + broadHeight);//ceilf(calculatedSize.height)
    return adjustedSize;
}

- (void)refreshTextViewSize:(UITextView *)textView
{
    DLog();
    CGSize size = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.frame), MAXFLOAT)];
    CGRect frame = textView.frame;
    frame.size.height = size.height;
    textView.frame = frame;
}


//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    DLog();
}


//结束编辑
//输入结束时调用动画（把按键。背景。输入框都移下去）
- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();
    [self endEditMoveDownAnimation];
    //释放
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)beginMoveUpAnimation:(int)height
{
    DLog();
    CGSize currentInputSize = _inputView.frame.size;
    _destinateFrame = CGRectMake(0, PJ_SCREEN_HEIGHT - (_inputViewSize.height + height) , currentInputSize.width, currentInputSize.height);
    [UIView animateWithDuration:0.2 animations:^{
        _inputView.frame = _destinateFrame;
    }];
}


- (void)endEditMoveDownAnimation
{
    DLog();
    CGSize currentInputSize = _inputView.frame.size;
    _destinateFrame = CGRectMake(0, PJ_SCREEN_HEIGHT - _inputViewSize.height , currentInputSize.width, currentInputSize.height);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _inputView.frame = _destinateFrame;
    } completion:nil];

}


- (IBAction)commitEvalutionAction:(id)sender {
    NSString* textStr = self.textView.text;
    DLog(@"%@",textStr);
    [self.textView resignFirstResponder];
    self.textView.text = @"";
    //发送信息到服务器，再获取数据返回刷新
}


@end
