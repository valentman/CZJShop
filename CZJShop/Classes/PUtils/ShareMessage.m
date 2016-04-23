//
//  ShareMessage.m
//  CheZhiJian
//
//  Created by chelifang on 15/8/11.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "ShareMessage.h"
#import "OpenShareHeader.h"


@interface ShareMessage ()

@end

@implementation ShareMessage{
    int _messageType;
    OSMessage* _shareMsg;
    NSString* _text;
    NSData *_smallImage,*_bigImage;
}


+ (ShareMessage *)shareMessage{
    static ShareMessage *sharedMsgManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMsgManager = [[self alloc] init];
    });
    return sharedMsgManager;
}

-(void)setMessageType:(int)type Text:(NSString*)text SmallImage:(UIImage*)simage {

}
-(void)showPanel:(UIView*)pView{
    
    NSArray *shareButtonTitleArray = [[NSArray alloc] init];
    NSArray *shareButtonImageNameArray = [[NSArray alloc] init];
    
    shareButtonTitleArray = @[@"微信好友",@"微信朋友圈",@"QQ好友",@"QQ空间",@"新浪微博"];
    shareButtonImageNameArray = @[
                                  @"share_icon_weixin",
                                  @"share_icon_pengyouquan",
                                  @"share_icon_qq",
                                  @"share_icon_zone",
                                  @"share_icon_weibo"];
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    [lxActivity showInView:pView];
}

-(void)showPanel:(UIView*)pView Type:(int)type WithTitle:(NSString*)title AndBody:(NSString*)body{
    [self showPanel:pView];
    
    _shareMsg = [[OSMessage alloc] init];
    _shareMsg.title = title;
//    _shareMsg.desc = body;
    _shareMsg.desc = [NSString stringWithFormat:@"%@",SHARE_CONTENT];
    _messageType = type;
}


-(void)weixinViewHandlerMsgType:(int)msgType MsgPlatform:(int)msgPlatform{
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title= _shareMsg.title;
    msg.desc = _shareMsg.desc;
    msg.link = SHARE_URL;

    switch (msgType) {
        case 1:
        {
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";
            msg.image=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
        }
            break;
        case 2:
        {
            //app
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";//分享到朋友圈以后，微信就不会调用app了，跟news类型分享到朋友圈一样。
            msg.image=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
        }
            
        default:
            break;
    }

    switch (msgPlatform) {
        case 1: //分享微信好友
        {
            if ([OpenShare isWeixinInstalled]) {
                [OpenShare shareToWeixinSession:msg Success:^(OSMessage *message) {
                    DLog(@"微信分享到会话成功：\n%@",message);
                } Fail:^(OSMessage *message, NSError *error) {
                    DLog(@"微信分享到会话失败：\n%@\n%@",error,message);
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装微信客户端，请安装后分享" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }
            
        }
            break;
        case 2://分享朋友圈
        {
            if ([OpenShare isWeixinInstalled])
            {
                [OpenShare shareToWeixinTimeline:msg Success:^(OSMessage *message) {
                    DLog(@"微信分享到朋友圈成功：\n%@",message);
                } Fail:^(OSMessage *message, NSError *error) {
                    DLog(@"微信分享到朋友圈失败：\n%@\n%@",error,message);
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装微信客户端，请安装后分享" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
            break;
        default:
            break;
    }
}

-(void)weiboViewHandlerMsgType:(int)msgType{
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title= _shareMsg.title;
    msg.desc = _shareMsg.desc;
    msg.link = SHARE_URL;
    
    switch (msgType) {
        case 1:
        {
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";
            msg.image=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
        }
            break;
        case 2:
        {
            //app
            msg.image= [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";
        }
            
        default:
            break;
    }
    
    if ([OpenShare isWeiboInstalled])
    {
        [OpenShare shareToWeibo:msg Success:^(OSMessage *message) {
            DLog(@"分享到sina微博成功:\%@",message);
        } Fail:^(OSMessage *message, NSError *error) {
            DLog(@"分享到sina微博失败:\%@\n%@",message,error);
        }];
    }
    else
    {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装新浪客户端，请安装后分享" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
        [alertview show];
    }
}

-(void)qqViewHandlerMsgType:(int)msgType MsgPlatform:(int)msgPlatform{
    OSMessage *msg=[[OSMessage alloc] init];
    msg.image=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_icon" ofType:@"png"]];
    
    msg.title= _shareMsg.title;
    msg.desc = _shareMsg.desc;
    msg.link = SHARE_URL;
    
    switch (msgType) {
        case 1:
        {
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";
        }
            break;
        case 2:
        {
            //app
//            msg.link=@"http://m.chezhijian.com/appserver/html/download.html";
        }
        default:
            break;
    }
    
    
    switch (msgPlatform) {
        case 1: //分享QQ好友
        {
            if ([OpenShare isQQInstalled])
            {
                [OpenShare shareToQQFriends:msg Success:^(OSMessage *message) {
                    DLog(@"分享到QQ好友成功:%@",msg);
                } Fail:^(OSMessage *message, NSError *error) {
                    DLog(@"分享到QQ好友失败:%@\n%@",msg,error);
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装QQ客户端，请安装后分享" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }

        }
            break;
        case 2://分享QQ空间
        {
            if ([OpenShare isQQInstalled])
            {
                [OpenShare shareToQQZone:msg Success:^(OSMessage *message) {
                    DLog(@"分享到QQ空间成功:%@",msg);
                } Fail:^(OSMessage *message, NSError *error) {
                    DLog(@"分享到QQ空间失败:%@\n%@",msg,error);
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIAlertView* alertview = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的手机未安装QQ客户端，请安装后分享" delegate:window cancelButtonTitle:@"收到" otherButtonTitles:nil, nil];
                [alertview show];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    DLog(@"%d",(int)imageIndex);
    switch ((int)imageIndex) {
        case 0:
        {
            [self weixinViewHandlerMsgType:_messageType MsgPlatform:1];
        }
            break;
        case 1:
        {
            [self weixinViewHandlerMsgType:_messageType  MsgPlatform:2];
        }
            break;
        case 2:
        {
            [self qqViewHandlerMsgType:_messageType MsgPlatform:1];
        }
            break;
        case 3:
        {
            [self qqViewHandlerMsgType:_messageType MsgPlatform:2];
        }
            break;
        case 4:
        {
            [self weiboViewHandlerMsgType:_messageType];
        }
            break;
            
        default:
            break;
    }
}

- (void)didClickOnCancelButton
{
    NSLog(@"didClickOnCancelButton");
}

@end
