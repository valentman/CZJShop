//
//  CZJLeaveMessageView.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJLeaveMessageView.h"

@interface CZJLeaveMessageView ()
<
UITextViewDelegate
>

@end

@implementation CZJLeaveMessageView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"留言";

    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(PJ_SCREEN_WIDTH - 50 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = BOLDSYSTEMFONT(16);
    
    [self.naviBarView addSubview:rightBtn];
    self.leaveMessageTextView.text = self.leaveMesageStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)done:(id)sender
{
    [self.delegate clickConfirmMessage:self.leaveMessageTextView.text];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
