//
//  ServiceProtocol.m
//  CheZhiJian
//
//  Created by chelifang on 15/9/7.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "ServiceProtocol.h"

@implementation ServiceProtocol


- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //定义navigationBar样式
//    [CZJUtils  setNavigationBarStayleForTarget:self];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _cur_url = [NSString stringWithFormat:@"%@/html/service.html",kCZJServerAddr];
    [self loadHtml:_cur_url];
    
    // Do any additional setup after loading the view.
}


- (void)loadHtml:(NSString *)surl{
    DLog(@"%@",surl);
    NSURL *url = [NSURL URLWithString:surl];
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
