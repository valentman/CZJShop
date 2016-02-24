//
//  CZJSBAlertView.m
//  CZJShop
//
//  Created by Joe.Pen on 2/24/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJSBAlertView.h"

@interface CZJSBAlertView ()

@end

@implementation CZJSBAlertView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView
{
    _popView = [CZJUtils getXibViewByName:@"CZJAlertView"];
    [_popView setWidth:PJ_SCREEN_WIDTH];
    [_popView setPosition:CGPointMake(PJ_SCREEN_WIDTH*0.5, PJ_SCREEN_HEIGHT*0.5) atAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.view addSubview:_popView];
    self.view.backgroundColor = CLEARCOLOR;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
