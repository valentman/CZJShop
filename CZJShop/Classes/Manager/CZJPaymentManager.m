//
//  CZJPaymentManager.m
//  CZJShop
//
//  Created by Joe.Pen on 3/14/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJPaymentManager.h"
#import "CZJBaseDataManager.h"
#import "payRequsestHandler.h"
#import "OpenShareHeader.h"

@implementation CZJPaymentManager
singleton_implementation(CZJPaymentManager);


- (void)weixinPay:(CZJPaymentOrderForm*)_orderDict{
    //请求支付的uil
    [CZJBaseDataInstance generalPost:@{@"payMethod":@"1"} success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSDictionary* subDict = [dict valueForKey:@"msg"];
        NSString* appid = [subDict valueForKey:@"appid"];
        NSString* partnerid = [subDict valueForKey:@"partnerid"];
        
        payRequsestHandler* tst = [payRequsestHandler alloc];
        [tst init:appid mch_id:partnerid];
        [tst setKey:PARTNER_ID];
        NSString* lk = [tst sendPayWithOrderInfo:[_orderDict keyValues]];
        
        if (lk) {
            [OpenShare WeixinPay:lk Success:^(NSDictionary *message) {
                DLog(@"微信支付成功:\n%@",message);
            } Fail:^(NSDictionary *message, NSError *error) {
                DLog(@"微信支付失败:\n%@\n%@",message,error);
            }];
        }
    } andServerAPI:kCZJServerAPIGetWeixinPayParams];
}

@end
