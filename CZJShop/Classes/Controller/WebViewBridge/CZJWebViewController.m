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
#import "IMYWebView.h"
#import "CZJCommitOrderController.h"
#import "ShareMessage.h"

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
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnMore.hidden = NO;
    [self.naviBarView.btnMore setBackgroundImage:IMAGENAMED(@"") forState:UIControlStateNormal];
    [self.naviBarView.btnMore setTitle:@"关闭" forState:UIControlStateNormal];
    [self.naviBarView.btnMore setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    
    //WebView定义
    self.myWebView.scrollView.emptyDataSetDelegate = self;
    self.myWebView.scrollView.emptyDataSetSource = self;
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64)];
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myWebView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myWebView.scrollView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    //webView JS交互接口
    self.webViewJSI = [CZJWebViewJSI bridgeForWebView:_myWebView webViewDelegate:self];
    self.webViewJSI.JSIDelegate = self;
    
    
    //URLRequest
    if (_cur_url)
    {
        NSURL *url = [NSURL URLWithString:_cur_url];
        [self loadHtml:url];
    }
}

- (void)loadHtml:(NSURL*)surl{
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
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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


#pragma mark - UIWebViewDelegate （WebView代理方法）
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.failedLoading = NO;
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.failedLoading = YES;
    [self.myWebView.scrollView reloadEmptyDataSet];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.naviBarView.mainTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    //网上找的解决Webview内存泄露的方法：
    //http://blog.csdn.net/primer_programer/article/details/24855329
    [USER_DEFAULT setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [USER_DEFAULT setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [USER_DEFAULT setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [USER_DEFAULT synchronize];
}


#pragma mark - jsActionDelegate （JS网页交互代理）
- (void)showGoodsOrServiceInfo:(NSDictionary*)dict
{
    NSLog(@"%@",dict);
    CZJDetailType detaitype = [[dict valueForKey:@"itemType"] integerValue] == 0 ? CZJDetailTypeGoods : CZJDetailTypeService;
    CZJGoodsPromotionType promotionType = [[dict valueForKey:@"promotionType"] integerValue];
    NSString* promotionPrice = [dict valueForKey:@"promotionPrice"];
    NSString* storeItemPid = [dict valueForKey:@"storeItemPid"];
    [CZJUtils showGoodsServiceDetailView:self.navigationController andItemPid:storeItemPid detailType:detaitype promotionType:promotionType promotionPrice:promotionPrice];
}

- (void)showStoreInfo:(NSString*)storeId
{
    [CZJUtils showStoreDetailView:self.navigationController andStoreId:storeId];
}

- (void)toSettleOrder:(NSArray*)_settleOrderAry andCouponUsable:(BOOL)couponUseable
{
    if ([CZJUtils isLoginIn:self andNaviBar:self.naviBarView])
    {
        UINavigationController* commitVC = (UINavigationController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"OrderSettleNavi"];
        CZJCommitOrderController* settleOrder = ((CZJCommitOrderController*)commitVC.topViewController);
        settleOrder.settleParamsAry = _settleOrderAry;
        settleOrder.isUseCouponAble = couponUseable;
        settleOrder.detaiViewType = CZJDetailTypeService;
        [self presentViewController:commitVC animated:YES completion:nil];
    }
}

-(void)showToast:(NSString*)msg
{
    [CZJUtils tipWithText:msg andView:self.navigationController.view];
}

- (void)toShare:(NSArray*)json
{
    NSString* desc = json.firstObject;
    NSString* imgUrl = json[1];
    NSString* title = json[3];
    NSString* shareUrl = json[2];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils downloadImageWithURL:imgUrl andFileName:@"storeShare_icon.png" withSuccess:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSData* imageData =[NSData dataWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:@"storeShare_icon.png"]];
        [[ShareMessage shareMessage] showPanel:self.view
                                          type:1
                                         title:title
                                          body:desc
                                          link:shareUrl
                                         image:imageData];
    } andFail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSData* imageData =[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
        [[ShareMessage shareMessage] showPanel:self.view
                                          type:1
                                         title:title
                                          body:desc
                                          link:shareUrl
                                         image:imageData];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}


@end
