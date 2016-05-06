//
//  WebViewJsBridge.m
//  VoxStudent
//
//  Created by zhaoxy on 14-3-8.
//  Copyright (c) 2014年 17zuoye. All rights reserved.
//

#import "WebViewJsBridge.h"
#import "CZJBaseDataManager.h"
#import <objc/runtime.h>

#define JsStr @"var chezhu = {}; (function how() { chezhu.getInfo = function () { return '%@';};})();"

@interface WebViewJsBridge ()

@property (nonatomic, weak) id webViewDelegate;
@property (nonatomic, weak) NSBundle *resourceBundle;

@end

@implementation WebViewJsBridge

+ (instancetype)bridgeForWebView:(UIWebView*)webView webViewDelegate:(NSObject<UIWebViewDelegate>*)webViewDelegate {
    return [self bridgeForWebView:webView webViewDelegate:webViewDelegate resourceBundle:nil];
}

+ (instancetype)bridgeForWebView:(UIWebView*)webView webViewDelegate:(NSObject<UIWebViewDelegate>*)webViewDelegate resourceBundle:(NSBundle*)bundle
{
    WebViewJsBridge* bridge = [[[self class] alloc] init];
    [bridge _platformSpecificSetup:webView webViewDelegate:webViewDelegate resourceBundle:bundle];
    return bridge;
}

#pragma mark - init & dealloc

- (void) _platformSpecificSetup:(UIWebView*)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate resourceBundle:(NSBundle*)bundle{
    _webView = webView;
    _webViewDelegate = webViewDelegate;
    _webView.delegate = self;
    _resourceBundle = bundle;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kCZJNotifiLoginSuccess object:nil];
}

- (void)dealloc {
    _webView.delegate = nil;
    _webView = nil;
    _webViewDelegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kCZJNotifiLoginSuccess object:nil];
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView != _webView) { return YES; }
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    
    //获取重定向URL，通过拦截重定向 URL的值来产生JS调用Native的方法
    NSURL *url = [request URL];
    NSString *requestString = [[request URL] absoluteString];
    
    //如果重定向URL里面含有定义好的协议（调用标识），则获取里面的调用函数名
    if ([requestString hasPrefix:kCustomProtocolScheme])
    {
        NSArray *components = [[url absoluteString] componentsSeparatedByString:@":"];
        
        //重定向URL里面JS调用Native的函数名
        NSString *function = (NSString*)[components objectAtIndex:1];
        
        //重定向URL里面JS传给Native的参数，并把JS参数数组转换成OC参数数组
        NSString *argsAsString = [(NSString*)[components objectAtIndex:2]
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *argsData = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *argsDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:argsData options:kNilOptions error:NULL];
        NSMutableArray *args = [NSMutableArray array];
        for (int i=0; i<[argsDic count]; i++)
        {
            [args addObject:[argsDic objectForKey:[NSString stringWithFormat:@"%d", i]]];
        }
        
        //从上面获取到了函数名和函数参数，通过运行时动态发送Native消息（执行Native函数）
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL selector = NSSelectorFromString([args count] > 0 ? [function stringByAppendingString:@":"] : function);
        if ([self respondsToSelector:selector])
        {
            [self performSelector:selector withObject:args];
        }
        return NO;
    }
    else if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    else
    {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [strongDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView != _webView) { return; }
    
    //是否有 javaScript嵌入在网页中
    if (![[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"typeof window.%@ == 'object'", kBridgeName]] isEqualToString:@"true"])
    {
        [self ingectJSString:webView];
    }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
}


#pragma mark - call js

//执行js方法
- (void)excuteJSWithObj:(NSString *)obj function:(NSString *)function {
    
    NSString *js = function;
    if (obj) {
        js = [NSString stringWithFormat:@"%@.%@", obj, function];
    }
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}


- (NSString*)getJavaScriptString
{
    NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"WebViewJsBridge" ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return js;
}

- (void)loginSuccess
{
    [_webView reload];
}

- (void)ingectJSString:(UIWebView*)webView
{
    //通过运行时，获取该类自己本身的方法名列表，在本项目中就是继承自该类的CZJWebViewJSI类的方法列表
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList([self class], &methodCount);
    NSMutableString *methodList = [NSMutableString string];
    for (int i=0; i<methodCount; i++) {
        //字符串转码成UTF8格式的NSString
        NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(methods[i])) encoding:NSUTF8StringEncoding];
        
        //防止隐藏的系统方法名包含“.”导致js报错
        if ([methodName rangeOfString:@"."].location!=NSNotFound) {
            continue;
        }
        [methodList appendString:@"\""];
        [methodList appendString:[methodName stringByReplacingOccurrencesOfString:@":" withString:@""]];
        [methodList appendString:@"\","];
    }
    if (methodList.length>0) {
        [methodList deleteCharactersInRange:NSMakeRange(methodList.length-1, 1)];
    }
    free(methods);
    
    //获取JSfunction字符串
    NSString* jsString = [self getJavaScriptString];
    
    //JS注入
    [CZJBaseDataInstance getSomeInfoSuccess:^(id dic){
        NSString* javastring = [NSString stringWithFormat:jsString, methodList, dic];
        [webView stringByEvaluatingJavaScriptFromString:javastring];
        DLog(@"\nwebView:%p, javastring:%@",_webView,javastring);
    }];
}

@end
