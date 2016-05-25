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
#import "CZJLoginModelManager.h"
#import "CZJAddedEvalutionCell.h"

@interface CZJUserEvalutionDetailController ()
<
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
    
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
    NSString* descStr;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewLayoutHeight;

- (IBAction)commitEvalutionAction:(id)sender;
@end

@implementation CZJUserEvalutionDetailController
@synthesize textView = _textView;
@synthesize inputView = _inputView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMydatas];
    [self initViews];
    [self registerForKeyboardNotifications];
    [self getReplyDataFromServer];
}

- (void)initMydatas
{
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.inputView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    _commitBtn.layer.cornerRadius = 5;
    _textView.layer.cornerRadius = 5;
    _textView.delegate = self;
    
    _originFrame = _inputView.frame;
    _inputViewSize = _originFrame.size;
    
    page = 1;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
}

- (void)initViews
{
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"评价详情";
    
    //TableView初始化
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    self.myTableView.tableFooterView = [[UIView alloc] init];
    self.myTableView.backgroundColor = WHITECOLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.myTableView reloadData];
    
    NSArray* nibArys = @[@"CZJEvalutionDetailCell",
                         @"CZJAddedEvalutionCell",
                         @"CZJEvalutionDescCell",
                         @"CZJEvalutionFooterCell",
                         @"CZJEvalutionDetailReplyCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    //------------添加到当前TableView中-----------
    __weak typeof(self) weakSelf = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weakSelf getReplyDataFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    CZJSuccessBlock successBlock = ^(id json)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        DLog(@"%@",[[CZJUtils DataFromJson:json] description]);
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [userEvalutionReplys addObjectsFromArray: [CZJEvalutionReplyForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 20)
            {
                [refreshFooter noticeNoMoreData];
            }
            else
            {
                [weakSelf.myTableView.footer endRefreshing];
            }
        }
        else
        {
            userEvalutionReplys = [[CZJEvalutionReplyForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
            if (userEvalutionReplys.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        
        
        if (userEvalutionReplys.count == 0)
        {
//            self.myTableView.hidden = YES;
//            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有浏览记录/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (userEvalutionReplys.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }
        
        
        
        
        [self.myTableView reloadData];
    };
    [CZJBaseDataInstance loadUserEvalutionReplys:@{@"evalId" : _evalutionForm.evaluateID}
                                            type:getDataTypeIsFresh
                                         Success:successBlock
                                            fail:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        BOOL isHaveAdded = [_evalutionForm.added boolValue];
        return isHaveAdded ? 4 : 3;
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
        CZJEvaluateForm* form = self.evalutionForm;
        if (indexPath.row == 0)
        {
            CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCell" forIndexPath:indexPath];

            [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:form.head] placeholderImage:IMAGENAMED(@"placeholder_personal")];
            cell.evalWriterName.text = form.name;
            cell.evalWriteTime.text = form.evalTime;
            return cell;
        }
        if (indexPath.row == 1)
        {
            CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
            cell.arrowNextImage.hidden = YES;
            [cell setStar:[form.score intValue]];
            cell.evalTime.text = nil;
            cell.evalWriter.text = nil;
            
            cell.evalContent.text = _evalutionForm.message;
            CGSize contenSize = [CZJUtils calculateStringSizeWithString:_evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
            cell.evalContentLayoutHeight.constant = contenSize.height;
            
            for (int i = 0; i < _evalutionForm.evalImgs.count; i++)
            {
                CGRect iamgeRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 10) size:CGSizeMake(78, 78) index:i divide:Divide];
                CZJImageView* evaluateImage = [[CZJImageView alloc]initWithFrame:iamgeRect];
                evaluateImage.subTag = i;
                evaluateImage.secondTag = 0;
                [evaluateImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)]];
                [evaluateImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_evalutionForm.evalImgs[i],SUOLUE_PIC_200]] placeholderImage:DefaultPlaceHolderSquare];
                
                [cell.picView addSubview:evaluateImage];
            }
            return cell;
        }
        if ([_evalutionForm.added boolValue] && 2 == indexPath.row)
        {
            CZJAddedEvalutionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddedEvalutionCell" forIndexPath:indexPath];
            cell.addedTimeLabel.text = _evalutionForm.addedEval.evalTime;
            cell.addedContentLabel.text = _evalutionForm.addedEval.message;
            float strHeight = [CZJUtils calculateStringSizeWithString:_evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
            cell.contentLabelHeight.constant = strHeight + 5;
            
            for (int i = 0; i < _evalutionForm.addedEval.evalImgs.count; i++)
            {
                NSString* url = _evalutionForm.addedEval.evalImgs[i];
                CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(70, 70) index:i divide:Divide];
                CZJImageView* imageView = [[CZJImageView alloc]initWithFrame:imageFrame];
                imageView.subTag = i;
                imageView.secondTag = 1;
                
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url,SUOLUE_PIC_200]] placeholderImage:DefaultPlaceHolderSquare];
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)]];
                [cell.picView addSubview:imageView];
            }
            
            return cell;
        }
        if (([_evalutionForm.added boolValue] && 3 == indexPath.row)||
            (![_evalutionForm.added boolValue] && 2 == indexPath.row))
        {
            CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
            [cell setVisibleView:kEvalDetailView];
            cell.serviceName.text = form.itemName;
            cell.serviceTime.text = form.orderTime;
            cell.form = form;
            cell.evalutionReplyBtn.hidden = YES;
            cell.addEvaluateBtn.hidden = YES;
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
                cell.textLabel.textColor = RGB(100, 100, 100);
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
            [cell.replyImage sd_setImageWithURL:[NSURL URLWithString:form.replyHead] placeholderImage:DefaultPlaceHolderSquare];
            cell.replyNameLabel.text = form.replyName;
            cell.replyTimeLabel.text = form.replyTime;
            cell.replyContentLabel.text = replyContent;
            cell.replyContentLayoutHeight.constant = contentSize.height;
            if (indexPath.row == userEvalutionReplys.count)
            {
                
                cell.separatorView.hidden = YES;
            }
            cell.separatorInset = HiddenCellSeparator;
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
            CGSize contenSize = [CZJUtils calculateStringSizeWithString:_evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
            NSInteger row = _evalutionForm.evalImgs.count / Divide + 1;
            NSInteger cellHeight = 60 + (contenSize.height > 20 ? contenSize.height : 20) + row * 88;
            return cellHeight;
        }
        if (2 == indexPath.row && [_evalutionForm.added boolValue])
        {
            float strHeight = [CZJUtils calculateStringSizeWithString:_evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40].height;
            float picViewHeight = 0;
            if (_evalutionForm.addedEval.evalImgs.count != 0)
            {
                picViewHeight = 70;
            }
            return 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
        }
        if ((2 == indexPath.row && ![_evalutionForm.added boolValue])||
            (3 == indexPath.row && [_evalutionForm.added boolValue]))
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
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
//    DLog(@"wewe:%@",[[UITextInputMode currentInputMode] primaryLanguage]);
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
    descStr = textView.text;
    
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
    [self.view endEditing:NO];

    if ([CZJUtils isBlankString:descStr])
    {
        [CZJUtils tipWithText:@"请发表一下你的想法在提交吧，亲~" andView:self.view];
        return;
    }
    //发送信息到服务器，再获取数据返回刷新
    __weak typeof(self) weakSelf = self;
    NSString* evaluid = _evalutionForm.evaluateID;
    UserBaseForm* userform = CZJBaseDataInstance.userInfoForm;
    NSString* headImg = userform.headPic;
    NSString* name = userform.name;
    NSDictionary* replyDict = @{@"evalId": evaluid,
                                @"replyHead" : headImg,
                                @"replyName": name,
                                @"replyDesc" :descStr};
    [CZJBaseDataInstance generalPost:replyDict success:^(id json) {
        [CZJUtils tipWithText:@"感谢回复" andView:weakSelf.view];
        [weakSelf getReplyDataFromServer];
        [weakSelf.textView resignFirstResponder];
        weakSelf.textView.text = @"";
    } fail:^{
        
    } andServerAPI:kCZJServerAPIReplyEvalution];
}

#pragma mark- 点小图显示大图
- (void)showBigImage:(UIGestureRecognizer*)recogonizer
{
    CZJImageView* evalutionImg = (CZJImageView*)recogonizer.view;
    if (evalutionImg.secondTag == 0)
    {//一级评价的图片
        [CZJUtils showDetailInfoWithIndex:evalutionImg.subTag withImgAry:_evalutionForm.evalImgs onTarget:self];
    }
    else
    {//追加评价的图片
        [CZJUtils showDetailInfoWithIndex:evalutionImg.subTag withImgAry:_evalutionForm.addedEval.evalImgs onTarget:self];
    }
}
@end
