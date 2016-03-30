//
//  CZJPicDetailBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJPicDetailBaseController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface CZJPicDetailBaseController ()
<
UIScrollViewDelegate,
UIWebViewDelegate
>
{
    BOOL _isBack;
}
@property (strong, nonatomic)UIWebView* myWebView;
@property (strong, nonatomic)UILabel* myLabel;

@end

@implementation CZJPicDetailBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 64 - 50 - 50)];
    self.myWebView.delegate = self;
    [self.view addSubview:_myWebView];
    _myWebView.scrollView.delegate = self;
    _myWebView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    _myLabel = [[UILabel alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH/2 - 75, 10, 150, 20)];
    _myLabel.textColor = RGB(30, 30, 30);
    _myLabel.font = SYSTEMFONT(12);
    _myLabel.textAlignment = NSTextAlignmentCenter;
    _myLabel.text = @"下拉回到“商品详情”";
    _myLabel.alpha = 0;
    [self.view addSubview:_myLabel];
    
    [self loadWebPageWithString:_detailUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:request];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.myWebView.scrollView reloadEmptyDataSet];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    if (contentOffsetY < 0)
    {
        float fbsOffset = fabs(contentOffsetY);
        float alphaValue = fbsOffset / 50;
        if (fbsOffset < 70)
        {
            self.myLabel.text = @"下拉回到“商品详情”";
            _isBack = NO;
        }
        else
        {
            self.myLabel.text = @"释放回到“商品详情”";
            _isBack = YES;
        }
        if (alphaValue > 1)
        {
            alphaValue = 1;
        }
        self.myLabel.alpha = alphaValue;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if (_isBack)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kCZJNotifiPicDetailBack object:nil];
    }
}

@end



@implementation CZJPicDetailController

- (void)viewDidLoad {
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsPicDetails;
    }
    else
    {
        apiType = kCZJServerAPIServicePicDetail;
    }
    self.detailUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJBuyNoticeController
- (void)viewDidLoad {
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsBuyNoteDetail;
    }
    else
    {
        apiType = kCZJServerAPIServiceBuyNoteDetail;
    }
    self.detailUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJAfterServiceController
- (void)viewDidLoad {
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsAfterSaleDetail;
    }
    else
    {
        apiType = kCZJServerAPIServicePicDetail;
    }
    self.detailUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJApplicableCarController
- (void)viewDidLoad {
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsCarModelList;
    }
    else
    {
        apiType = kCZJServerAPIServiceCarModelsList;
    }
    self.detailUrl = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
