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
#import "AliPayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CZJOrderPaySuccessController.h"
#import "CZJCommitOrderController.h"

@implementation CZJPaymentManager
singleton_implementation(CZJPaymentManager);


- (void)weixinPay:(CZJViewController*)target
        OrderInfo:(CZJPaymentOrderForm*)_orderDict
          Success:(paySuccess)sucsess
             Fail:(payFail)fail
{
    self.targetViewController = target;
    _paymentOrderForm = _orderDict;
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
        
        __weak typeof(self) weak = self;
        if (lk) {
            [OpenShare WeixinPay:lk Success:^(NSDictionary *message) {
                [weak jumpToSuc:message];
            } Fail:^(NSDictionary *message, NSError *error) {
                fail(message,error);
            }];
        }
    } andServerAPI:kCZJServerAPIGetWeixinPayParams];
}

- (void)aliPay:(CZJViewController*)target
     OrderInfo:(CZJPaymentOrderForm*)_orderDict
       Success:(paySuccess)success
          Fail:(payFail)fail
{
    _paymentOrderForm = _orderDict;
    self.targetViewController = target;
    __weak typeof(self) weak = self;
    AliPayManager* tmp =[[AliPayManager alloc] init];
    [tmp generateWithOrderDict:[_orderDict keyValues] Success:^(NSDictionary *message) {
        [weak jumpToSuc:message];
    } Fail:^(NSDictionary *message, NSError *error) {
        fail(message,error);
    }];
}

-(void)jumpToSuc:(id)info
{
    UINavigationController* mynavi = self.targetViewController.navigationController;
    [mynavi popViewControllerAnimated:NO];
    
    CZJOrderPaySuccessController *paySuccessVC = (CZJOrderPaySuccessController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDPaymentSuccess];
    paySuccessVC.orderNo= _paymentOrderForm.order_no;
    paySuccessVC.orderPrice = _paymentOrderForm.order_price;
    [mynavi pushViewController:paySuccessVC animated:YES];
}

@end
