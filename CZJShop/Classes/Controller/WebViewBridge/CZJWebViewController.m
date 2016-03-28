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
    
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnMore.hidden = NO;
    [self.naviBarView.btnMore setBackgroundImage:IMAGENAMED(@"") forState:UIControlStateNormal];
    [self.naviBarView.btnMore setTitle:@"关闭" forState:UIControlStateNormal];
    [self.naviBarView.btnMore setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [self.naviBarView.btnMore addTarget:self action:@selector(clickEventCallBack:) forControlEvents:UIControlEventTouchUpInside];
    
    //webView接口
    self.webViewJSI = [CZJWebViewJSI bridgeForWebView:_myWebView webViewDelegate:self];
    self.webViewJSI.JSIDelegate = self;
    
    //webView
    self.myWebView.scrollView.emptyDataSetDelegate = self;
    self.myWebView.scrollView.emptyDataSetSource = self;
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64)];
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myWebView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    //URLRequest
    if (_cur_url)
    {
        NSURL *url = [NSURL URLWithString:_cur_url];
        [self loadHtml:url];
    }
}

- (void)loadHtml:(NSURL*)surl{
    DLog(@"%@",surl);
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:surl]];
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


#pragma mark - CZJNaviagtionBarViewDelegate(自定义导航栏按钮回调)
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case CZJButtonTypeNaviBarBack:
            if ([self.myWebView canGoBack])
            {
                [self.myWebView goBack];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.failedLoading = YES;
    [self.myWebView.scrollView reloadEmptyDataSet];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.naviBarView.mainTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
