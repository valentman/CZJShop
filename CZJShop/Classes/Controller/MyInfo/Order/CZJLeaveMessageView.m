//
//  CZJLeaveMessageView.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJLeaveMessageView.h"

@interface CZJLeaveMessageView ()

@end

@implementation CZJLeaveMessageView

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];

    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = BOLDSYSTEMFONT(16);
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: rightBtn];
    if ((IS_IOS7 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = 0 ;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
        
    } else
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
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
