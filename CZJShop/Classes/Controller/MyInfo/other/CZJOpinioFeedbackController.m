//
//  CZJOpinioFeedbackController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOpinioFeedbackController.h"

@interface CZJOpinioFeedbackController ()

@end

@implementation CZJOpinioFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    
    
    CGRect rect = CGRectMake(20, 64, PJ_SCREEN_WIDTH- 40, 200);
    CZJTextView *textView = [[CZJTextView alloc]initWithFrame:rect];
    [textView setBackgroundColor:CZJNAVIBARGRAYBG];
    [textView setMyPlaceholder:@"请输入您宝贵的意见，以便我们不断优化体验"];
    [textView setMyPlaceholderColor:[UIColor lightGrayColor]];
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
