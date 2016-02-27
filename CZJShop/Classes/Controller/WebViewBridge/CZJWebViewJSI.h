//
//  CZJWebViewJSI.h
//  CZJShop
//
//  Created by Joe.Pen on 2/27/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJsBridge.h"

//实现这个代理的是NativeVC，也就是CZJWebViewController
@protocol jsActionDelegate <NSObject>

@optional
-(void)callUp:(NSString*)tel;
-(void)moreCommentActionWithId:(NSDictionary*)dict;
-(void)guidedSystemWithLng:(double)lng Lat:(double)lat CityName:(NSString*)name;
-(void)viewServiceItemWithId:(NSString*)itemId;
-(void)buyWithInfo:(NSDictionary*)dict;
-(void)setTitle:(NSString*)msg;
-(void)showCarType:(NSString*)msg;
-(void)showToast:(NSString*)msg;
- (void)showGoodsOrServiceInfo:(NSString*)storeItemPid;
- (void)showStoreInfo:(NSString*)storeId;
- (void)toSettleOrder:(NSString*)goodsInfo andCount:(int)count;
@end

@interface CZJWebViewJSI : WebViewJsBridge

@property (nonatomic, assign) id<jsActionDelegate> JSIDelegate;

//所有以下的这些方法都是跟JS绑定好了的。
-(void)call:(NSArray *)tel;
-(void)routeGuide:(NSArray *)routeGuide;
-(void)moreComment:(NSArray *)comment;
-(void)viewServiceItem:(NSArray *)item;
-(void)buy:(NSArray*)msg;
-(void)setTitle:(NSArray*)msg;
-(void)showCarType:(NSArray*)cars;

- (void)toGoodsOrServiceInfo:(NSArray*)json;           //跳转到商品或服务详情
- (void)toStoreInfo:(NSArray*)json;                    //跳转到门店详情
- (void)jiesuan:(NSArray*)json andCount:(int)count;    //结算
- (void)showToast:(NSString*)json;                      //提示框
- (void)getChezhuInfo;                                //获取车主信息
@end
