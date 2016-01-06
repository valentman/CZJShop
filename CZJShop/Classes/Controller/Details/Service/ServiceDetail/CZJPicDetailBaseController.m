//
//  CZJPicDetailBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJPicDetailBaseController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface CZJPicDetailBaseController ()<UIScrollViewDelegate>
{
    BOOL _isBack;
}
@property (strong, nonatomic)UIWebView* myWebView;
@property (strong, nonatomic)UILabel* myLabel;

@end

@implementation CZJPicDetailBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_myWebView];
    _myWebView.scrollView.delegate = self;
    
    _myLabel = [[UILabel alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH/2 - 75, 10, 150, 20)];
    _myLabel.textColor = [UIColor whiteColor];
    _myLabel.font = SYSTEMFONT(12);
    _myLabel.textAlignment = NSTextAlignmentCenter;
    _myLabel.text = @"下拉回到“商品详情”";
    _myLabel.alpha = 0;
    [self.view addSubview:_myLabel];
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
    [SVProgressHUD show];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.myWebView.scrollView reloadEmptyDataSet];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float contentOffsetY = [scrollView contentOffset].y;
    DLog(@"tag:%ld, %f",scrollView.tag, contentOffsetY);
    
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


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    DLog();
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    DLog();
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
        DLog();
//    float contentOffsetY = [scrollView contentOffset].y;
//    if (1002 == scrollView.tag && contentOffsetY == 0)
//    {
//        //        self.myScrollView.scrollEnabled = NO;
//        [self.myScrollView setContentOffset:CGPointMake(0, -20) animated:true];
//        isButtom = NO;
//    }
//    if (1002 == scrollView.tag && contentOffsetY == 576) {
//        [self.myScrollView setContentOffset:CGPointMake(0, 602) animated:true];
//    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    DLog();
}

@end
