//
//  LXActivity.m
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "LXActivity.h"
#import "AppDelegate.h"

//系统
#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor colorWithRed:238/255.00f green:238/255.00f blue:238/255.00f alpha:1.0]
#define ANIMATE_DURATION                        0.25f
#define DIVIDENUMBER                            3
//分享按钮
#define CORNER_RADIUS                           30
#define SHAREBUTTON_BORDER_WIDTH                0.5f
#define SHAREBUTTON_BORDER_COLOR                [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:0.8].CGColor
#define SHAREBUTTON_WIDTH                       60
#define SHAREBUTTON_HEIGHT                      60
#define SHAREBUTTON_INTERVAL_WIDTH              (PJ_SCREEN_WIDTH - SHAREBUTTON_WIDTH * 3)/4.0f
#define SHAREBUTTON_INTERVAL_HEIGHT             35

//分享按钮标题
#define SHARETITLE_WIDTH                        70
#define SHARETITLE_HEIGHT                       20
#define SHARETITLE_INTERVAL_WIDTH               (PJ_SCREEN_WIDTH - SHARETITLE_WIDTH * 3)/4.0f
#define SHARETITLE_INTERVAL_HEIGHT              SHAREBUTTON_WIDTH+SHAREBUTTON_INTERVAL_HEIGHT

//总标题
#define TITLE_INTERVAL_HEIGHT                   20
#define TITLE_HEIGHT                            20
#define TITLE_INTERVAL_WIDTH                    30
#define TITLE_WIDTH                             260
#define TITLE_FONT                              [UIFont fontWithName:@"Helvetica-Bold" size:10]
#define SHADOW_OFFSET                           CGSizeMake(0, 0.8f)
#define TITLE_NUMBER_LINES                      2

//取消按钮
#define BUTTON_INTERVAL_HEIGHT                  8
#define BUTTON_HEIGHT                           44
#define BUTTON_INTERVAL_WIDTH                   15
#define BUTTON_WIDTH                            44
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define BUTTON_BORDER_WIDTH                     0.2f
#define BUTTON_BORDER_COLOR                     [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor
#define CANCEL_BUTTON_COLOR                     [UIColor colorWithRed:255/255.00f green:255/255.00f blue:255/255.00f alpha:1]


@interface UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@implementation UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

@interface LXActivity ()

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadShareButton;
@property (nonatomic,assign) BOOL isHadCancelButton;
@property (nonatomic,assign) CGFloat LXActivityHeight;
@property (nonatomic,assign) id<LXActivityDelegate>delegate;

@end

@implementation LXActivity

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;
{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        [self creatButtonsWithTitle:title cancelButtonTitle:cancelButtonTitle shareButtonTitles:shareButtonTitlesArray withShareButtonImagesName:shareButtonImagesNameArray];
        
    }
    return self;
}

- (void)showInView:(UIView *)view
{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//    UIViewController *topVC = appRootVC;
//    while (topVC.presentedViewController) {
//        topVC = topVC.presentedViewController;
//    }
    
    
    AppDelegate* mydelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mydelegate.window addSubview:self];
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    [window addSubview:self];
}

#pragma mark - Praviate method

- (void)creatButtonsWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle shareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray
{
    //初始化
    self.isHadTitle = NO;
    self.isHadShareButton = NO;
    self.isHadCancelButton = NO;
    
    //初始化LXACtionView的高度为0
    self.LXActivityHeight = 20;
    
    //初始化IndexNumber为0;
    self.postionIndexNumber = 0;
    
    //生成LXActionSheetView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.backGroundView.backgroundColor = ACTIONSHEET_BACKGROUNDCOLOR;
    
    //给LXActionSheetView添加响应事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
    [self.backGroundView addGestureRecognizer:tapGesture];
    
    [self addSubview:self.backGroundView];
    
    if (title) {
        self.isHadTitle = YES;
        UILabel *titleLabel = [self creatTitleLabelWith:title];
        titleLabel.textColor = [UIColor grayColor];
        self.LXActivityHeight = self.LXActivityHeight + 2*TITLE_INTERVAL_HEIGHT+TITLE_HEIGHT;
        [self.backGroundView addSubview:titleLabel];
        
        UIView* separatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, PJ_SCREEN_WIDTH, SHAREBUTTON_BORDER_WIDTH)];
        separatorView.backgroundColor = [UIColor lightGrayColor];
        [self.backGroundView addSubview:separatorView];
        
    }
    
    if (shareButtonImagesNameArray) {
        if (shareButtonImagesNameArray.count > 0) {
            self.isHadShareButton = YES;
            for (int i = 1; i < shareButtonImagesNameArray.count+1; i++) {
                //计算出行数，与列
                int column = (int)ceil((float)(i)/DIVIDENUMBER); //行
                int line = (i)%DIVIDENUMBER; //列
                if (line == 0) {
                    line = DIVIDENUMBER;
                }
                UIButton *shareButton = [self creatShareButtonWithColumn:column andLine:line];
                shareButton.layer.cornerRadius = CORNER_RADIUS;
                shareButton.layer.borderWidth = SHAREBUTTON_BORDER_WIDTH;
                shareButton.layer.borderColor = SHAREBUTTON_BORDER_COLOR;
                shareButton.tag = self.postionIndexNumber;
                [shareButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
                
                [shareButton setBackgroundImage:[UIImage imageNamed:[shareButtonImagesNameArray objectAtIndex:i-1]] forState:UIControlStateNormal];
                //有Title的时候
                if (self.isHadTitle == YES) {
                    [shareButton setFrame:CGRectMake(SHAREBUTTON_INTERVAL_WIDTH+((line-1)*(SHAREBUTTON_INTERVAL_WIDTH+SHAREBUTTON_WIDTH)), self.LXActivityHeight+((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
                }
                else{
                    [shareButton setFrame:CGRectMake(SHAREBUTTON_INTERVAL_WIDTH+((line-1)*(SHAREBUTTON_INTERVAL_WIDTH+SHAREBUTTON_WIDTH)), SHAREBUTTON_INTERVAL_HEIGHT+((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
                }
                [self.backGroundView addSubview:shareButton];
                
                self.postionIndexNumber++;
            }
        }
    }
    
    if (shareButtonTitlesArray) {
        if (shareButtonTitlesArray.count > 0 && shareButtonImagesNameArray.count > 0) {
            for (int j = 1; j < shareButtonTitlesArray.count+1; j++) {
                //计算出行数，与列数
                int column = (int)ceil((float)(j)/DIVIDENUMBER); //行
                int line = (j)%DIVIDENUMBER; //列
                if (line == 0) {
                    line = DIVIDENUMBER;
                }
                UILabel *shareLabel = [self creatShareLabelWithColumn:column andLine:line];
                shareLabel.text = [shareButtonTitlesArray objectAtIndex:j-1];
                shareLabel.textAlignment = NSTextAlignmentCenter;
                shareLabel.font = SYSTEMFONT(14);
                //有Title的时候
                if (self.isHadTitle == YES) {
                    [shareLabel setFrame:CGRectMake(SHARETITLE_INTERVAL_WIDTH+((line-1)*(SHARETITLE_INTERVAL_WIDTH+SHARETITLE_WIDTH)), self.LXActivityHeight+SHAREBUTTON_HEIGHT+((column-1)*(SHARETITLE_INTERVAL_HEIGHT)), SHARETITLE_WIDTH, SHARETITLE_HEIGHT)];
                }
                shareLabel.textColor = [UIColor grayColor];
                [self.backGroundView addSubview:shareLabel];
            }
        }
    }
    
    //再次计算加入shareButtons后LXActivity的高度
    if (shareButtonImagesNameArray && shareButtonImagesNameArray.count > 0) {
        int totalColumns = (int)ceil((float)(shareButtonImagesNameArray.count)/4);
        if (self.isHadTitle  == YES) {
            self.LXActivityHeight = self.LXActivityHeight + totalColumns*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT);
        }
        else{
            self.LXActivityHeight = SHAREBUTTON_INTERVAL_HEIGHT + totalColumns*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT);
        }
    }
    
    if (cancelButtonTitle) {
        self.isHadCancelButton = YES;
        UIButton *cancelButton = [cancelButtonTitle isEqualToString:@""] ? [self creatCancelButtonWith] : [self creatCancelButtonWith:cancelButtonTitle];
        cancelButton.tag = self.postionIndexNumber;
        [cancelButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
        
        //
        if (![cancelButtonTitle isEqualToString:@""]) {
            //当没title destructionButton otherbuttons时
            if (self.isHadTitle == NO && self.isHadShareButton == NO) {
                self.LXActivityHeight = self.LXActivityHeight + cancelButton.frame.size.height+(2*BUTTON_INTERVAL_HEIGHT);
            }
            //当有title或destructionButton或otherbuttons时
            if (self.isHadTitle == YES || self.isHadShareButton == YES) {
                [cancelButton setFrame:CGRectMake(cancelButton.frame.origin.x, self.LXActivityHeight, cancelButton.frame.size.width, cancelButton.frame.size.height)];
                self.LXActivityHeight = self.LXActivityHeight + cancelButton.frame.size.height+BUTTON_INTERVAL_HEIGHT;
            }
        }

        [self.backGroundView addSubview:cancelButton];
        self.postionIndexNumber++;
    }
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.LXActivityHeight, [UIScreen mainScreen].bounds.size.width, self.LXActivityHeight)];
    } completion:^(BOOL finished) {
    }];
}


- (UIButton *)creatCancelButtonWith
{
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - BUTTON_WIDTH- BUTTON_INTERVAL_WIDTH, BUTTON_INTERVAL_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [cancelButton setImage:IMAGENAMED(@"login_btn_off") forState:UIControlStateNormal];
    
    return cancelButton;
}


- (UIButton *)creatCancelButtonWith:(NSString *)cancelButtonTitle
{
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_INTERVAL_WIDTH, BUTTON_INTERVAL_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.cornerRadius = CORNER_RADIUS;
    
    cancelButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    cancelButton.layer.borderColor = BUTTON_BORDER_COLOR;

    UIImage *image = [UIImage imageWithColor:CANCEL_BUTTON_COLOR];
    [cancelButton setBackgroundImage:image forState:UIControlStateNormal];

    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = BUTTONTITLE_FONT;
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    return cancelButton;
}

- (UIButton *)creatShareButtonWithColumn:(int)column andLine:(int)line
{
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SHAREBUTTON_INTERVAL_WIDTH+((line-1)*(SHAREBUTTON_INTERVAL_WIDTH+SHAREBUTTON_WIDTH)), SHAREBUTTON_INTERVAL_HEIGHT+((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
    return shareButton;
}

- (UILabel *)creatShareLabelWithColumn:(int)column andLine:(int)line
{
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(SHARETITLE_INTERVAL_WIDTH+((line-1)*(SHARETITLE_INTERVAL_WIDTH+SHARETITLE_WIDTH)), SHARETITLE_INTERVAL_HEIGHT+((column-1)*(SHARETITLE_INTERVAL_HEIGHT)), SHARETITLE_WIDTH, SHARETITLE_HEIGHT)];
    
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.font = TITLE_FONT;
    shareLabel.textColor = [UIColor whiteColor];
    return shareLabel;
}

- (UILabel *)creatTitleLabelWith:(NSString *)title
{
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - TITLE_WIDTH) / 2, TITLE_INTERVAL_HEIGHT, TITLE_WIDTH, TITLE_HEIGHT)];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.shadowOffset = SHADOW_OFFSET;
    titlelabel.font = SYSTEMFONT(16);
    titlelabel.text = title;
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.numberOfLines = TITLE_NUMBER_LINES;
    return titlelabel;
}

- (void)didClickOnImageIndex:(UIButton *)button
{
    if (self.delegate) {
        if (button.tag != self.postionIndexNumber-1) {
            if ([self.delegate respondsToSelector:@selector(didClickOnImageIndex:)] == YES) {
                [self.delegate didClickOnImageIndex:(NSInteger *)button.tag];
            }
        }
        else{
            if ([self.delegate respondsToSelector:@selector(didClickOnCancelButton)] == YES){
                [self.delegate didClickOnCancelButton];
            }
        }
    }
    [self tappedCancel];
}

- (void)tappedCancel
{
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)tappedBackGroundView
{
    //
    
}

@end
