//
//  AliPayManager.m
//  CheZhiJian
//
//  Created by chelifang on 15/8/8.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "AliPayManager.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation AliPayManager

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

- (const char *)UnicodeToISO88591:(NSString *)src
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    return [src cStringUsingEncoding:enc];
}

- (NSString*)generateWithOrderDict:(NSDictionary*)dict{

    NSString *partner = @"2088021227083481";
    NSString *seller = @"2088021227083481";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK85vtYuZF7tvCsei4VNIfMToBlCIJBTPIJJMvTjaHQSdxVGeMd7yKuRHZ33SVRVkNjg2lYN2ufftDQSIsrP0dwep42hsQFzk225th7Kf945019xtYbt8wV5JVPPTZGw5hbOQMn97JIzn0Hj1ogmp7A6T0P1kYk7lKmIDUD7FgqPAgMBAAECgYAkHQ+izu7qza6BaIsyzwHXOk09x240sKMA6xswc4n8mi2m2d5cprtl+MOU4flgAz6WJEl7gOGD9owKS06WZByJHQlH/Ke5sGp/+VOY/YWSQZi257+GUQ7ClsCYSiIK8In/weZk4FILAYa7OZl+caIDk9bD/ZdFw1I3M+E4QC5YcQJBANiL91MRvs/RIwkoLC8JWphUiLOXgnUeZckYj0CPQ5hd5tVhJcBKSqGAd3RxqX0M6I4Eqzb+J16GrsCXwnlVnkcCQQDPJoDyuUue7B0q4toKsDFaIzDf/0/p0+Qss39r9USNJtt//NVpHSpfRiRmPrdeybQ1/5VYVmdA/rGGAXrD9m15AkEAjXIfgys8MBKzh++trKu3eXj+MhDtLgNFCS35pHnv9T6g4RAr0Ia2aPe5D16PDxe3b8ys6abpoFzpGPQIG6lJUQJAGNQFmpII9UhZip1cAvHxSFt1bTOdsWn7LDxrZlYkXEKvBl0YexvKy1aN4E9eDRdh6SL0FH1urMSaJHSi8T/lCQJAE+eXAGcNBSqsxU0l6ERxe25DYXOzlJ/zXh1kG8yYR9tVKVYVxqlGn6Mgsg10ae5Z07/3Eb+kUTRiYwmNb1FNfQ==";
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    
//    NSDictionary* test = [dict mutableCopy];
//    NSString* tradeno = [NSString stringWithString:];
//    NSString* orderName = @"测试一下";//[dict valueForKey:@"order_name"];
//    NSString* description = @"测试一下";//[dict valueForKey:@"order_description"];

    order.tradeNO = [dict  valueForKey:@"order_no"];
    order.productName = [dict valueForKey:@"order_name"];
    order.productDescription =[dict valueForKey:@"order_description"];
    order.amount = [dict valueForKey:@"order_price"];//[dict valueForKey:@"order_price"];//[NSString stringWithFormat:@"%.2f",0.01];//[dict valueForKey:@"order_price"];
    
    
//    order.tradeNO = @"10000404"; //订单ID（由商家自行制定）
//    order.productName = @"nihaohao"; //商品标题
//    order.productDescription = @"ceshishuju"; //商品描述
//    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.notifyURL =  @"http://m.chezhijian.com/appserver/chezhu/notifyForZhifubao.do"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    NSString *orderSpec = [order description];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    NSString* appScheme = @"CheZhiJian";
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
//        $dataString.='&sign_type="RSA"&bizcontext="{"appkey":"2014052600006128"}"&sign="'.$sign.'"';
//        orderString = [NSString stringWithFormat:@"&sign_type=\"RSA\"&bizcontext=\"{\"appkey\":\"2015080600201657\"}\"&sign=\"%@\"",signedString];
//        $iOSLink= "alipay://alipayclient/?".urlencode(json_encode(array('requestType' => 'SafePay', "fromAppUrlScheme" => /*iOS App的url schema，支付宝回调用*/"openshare","dataString"=>$dataString)));
        NSLog(@"--%@",orderString);
//        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"SafePay",@"requestType",
//                             @"CheZhiJian", @"fromAppUrlScheme",
//                              orderString,@"dataString",nil];
        
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut-- = %@",resultDic);
            if ([[resultDic valueForKey:@"resultStatus"] intValue] == 9000) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCZJAlipaySuccseful object:resultDic];
            }
        }];

         
//        NSData* data = [Tools JsonFormData:dict];
//        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSString* iOSLink = [NSString stringWithFormat:@"alipay://alipayclient/?%@",aString];
        
        
        NSString * str_ios = [NSString stringWithFormat:@"alipay://alipayclient/?{\"requestType\":\"SafePay\",\"fromAppUrlScheme\":\"CheZhiJian\",dataString:\"%@\"}",orderString];
 //       [[AlipaySDK defaultService] processOrderWithPaymentResult:[NSURL URLWithString:iOSLink] standbyCallback:^(NSDictionary *resultDic) {
 //           NSLog(@"reslut = %@",resultDic);
 //       }];
         
        return str_ios;
    }
    return nil;
}

@end
