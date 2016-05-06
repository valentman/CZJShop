//
//  ShareMessage.h
//  CheZhiJian
//
//  Created by chelifang on 15/8/11.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenShare.h"
#import "LXActivity.h"

@interface ShareMessage : NSObject<LXActivityDelegate>

+ (ShareMessage *)shareMessage;
-(void)setMessageType:(int)type Text:(NSString*)text SmallImage:(UIImage*)image;
-(void)weixinViewHandlerMsgType:(int)msgType MsgPlatform:(int)msgPlatform;
-(void)weiboViewHandlerMsgType:(int)msgType;
-(void)qqViewHandlerMsgType:(int)msgType MsgPlatform:(int)msgPlatform;
-(void)showPanel:(UIView*)pView;
-(void)showPanel:(UIView*)pView Type:(int)type WithTitle:(NSString*)title AndBody:(NSString*)body;
-(void)showPanel:(UIView*)pView
            type:(int)type
           title:(NSString*)title
            body:(NSString*)body
            link:(NSString*)url
           image:(NSData*)imageData;
@end
