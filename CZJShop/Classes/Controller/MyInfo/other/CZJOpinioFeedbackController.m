//
//  CZJOpinioFeedbackController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOpinioFeedbackController.h"
#import "CZJBaseDataManager.h"

@interface CZJOpinioFeedbackController ()

@property (strong, nonatomic) CZJTextView *textView;
- (IBAction)confirmAction:(id)sender;
@end

@implementation CZJOpinioFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnBack.hidden = YES;
    
    CGRect rect = CGRectMake(20, 84, PJ_SCREEN_WIDTH- 40, 200);
    _textView = [[CZJTextView alloc]initWithFrame:rect];
    [_textView setBackgroundColor:CZJNAVIBARBGCOLOR];
    [_textView setMyPlaceholder:@"请输入您宝贵的意见，以便我们不断优化体验"];
    [_textView setMyPlaceholderColor:[UIColor lightGrayColor]];
    _textView.layer.cornerRadius = 5;
    [self.view addSubview:_textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)confirmAction:(id)sender
{
    [self.view endEditing:YES];
    NSDictionary* params = @{@"suggestion.content" : _textView.text,@"suggestion.mobile": CZJBaseDataInstance.userInfoForm.mobile};
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        
    } fail:^{
        
    } andServerAPI:kCZJServerAPIFeedBack];
}
@end
