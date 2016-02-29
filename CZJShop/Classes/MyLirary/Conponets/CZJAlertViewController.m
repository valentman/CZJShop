//
//  CZJAlertViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/24/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAlertViewController.h"
#import "CZJAlertView.h"

@interface CZJAlertViewController ()

@end

@implementation CZJAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView
{
    UIView* popView = [CZJUtils getXibViewByName:@"CZJAlertView"];
    [popView setPosition:CGPointMake(PJ_SCREEN_WIDTH*0.5, PJ_SCREEN_HEIGHT*0.5) atAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.view addSubview:popView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
