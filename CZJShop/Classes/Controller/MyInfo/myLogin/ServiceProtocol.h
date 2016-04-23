//
//  ServiceProtocol.h
//  CheZhiJian
//
//  Created by chelifang on 15/9/7.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceProtocol : CZJViewController<UIGestureRecognizerDelegate,UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *myWebView;
@property(nonatomic,strong)NSString* cur_url;
@end
