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
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"用户注册及服务协议";
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _cur_url = [NSString stringWithFormat:@"%@html/service.html",kCZJServerAddr];
    
    
    //WebView定义
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64)];
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myWebView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    [self loadHtml:_cur_url];
    // Do any additional setup after loading the view.
}


- (void)loadHtml:(NSString *)surl{
    DLog(@"%@",surl);
    NSURL *url = [NSURL URLWithString:surl];
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
}

@end
