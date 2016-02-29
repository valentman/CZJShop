//
//  CZJWebViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/27/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJWebViewController.h"
#import "CZJWebViewJSI.h"
#import "UIScrollView+EmptyDataSet.h"

@interface CZJWebViewController ()
<
UIWebViewDelegate,
jsActionDelegate,
DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate
>
{
    
}
@property (strong, nonatomic)CZJWebViewJSI* webViewJSI;
@property (strong, nonatomic)UIWebView* myWebView;
@property (nonatomic, getter=didFailLoading) BOOL failedLoading;

@end

@implementation CZJWebViewController
@synthesize cur_url = _cur_url;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self loadHtml:_cur_url];
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    
    //webView接口
    self.webViewJSI = [CZJWebViewJSI bridgeForWebView:_myWebView webViewDelegate:self];
    self.webViewJSI.JSIDelegate = self;
    
    //webView
    self.myWebView.scrollView.emptyDataSetDelegate = self;
    self.myWebView.scrollView.emptyDataSetSource = self;
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64)];
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
}

- (void)loadHtml:(NSString *)surl{
    DLog(@"%@",surl);
    NSURL *url = [NSURL URLWithString:surl];
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.failedLoading = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.failedLoading = YES;
    [self.myWebView.scrollView reloadEmptyDataSet];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark - jsActionDelegate
-(void)callUp:(NSString*)tel
{
    
}

-(void)moreCommentActionWithId:(NSDictionary*)dict
{
}

-(void)guidedSystemWithLng:(double)lng Lat:(double)lat CityName:(NSString*)name
{
}

-(void)viewServiceItemWithId:(NSString*)itemId
{
    
}

-(void)buyWithInfo:(NSDictionary*)dict
{
    
}

-(void)setTitle:(NSString*)msg
{
}

-(void)showCarType:(NSString*)msg
{
}

-(void)showToast:(NSString*)msg
{
}

- (void)showGoodsOrServiceInfo:(NSString*)storeItemPid
{
}

- (void)showStoreInfo:(NSString*)storeId
{
}

- (void)toSettleOrder:(NSString*)goodsInfo andCount:(int)count
{
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


@end
