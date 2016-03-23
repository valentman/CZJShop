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
    srand((unsigned)time(0));
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

- (void)generateWithOrderDict:(NSDictionary*)dict
                      Success:(paySuccess)success
                         Fail:(payFail)fail
{

    NSString *partner = @"2088021227083481";
    NSString *seller = @"2088021227083481";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK85vtYuZF7tvCsei4VNIfMToBlCIJBTPIJJMvTjaHQSdxVGeMd7yKuRHZ33SVRVkNjg2lYN2ufftDQSIsrP0dwep42hsQFzk225th7Kf945019xtYbt8wV5JVPPTZGw5hbOQMn97JIzn0Hj1ogmp7A6T0P1kYk7lKmIDUD7FgqPAgMBAAECgYAkHQ+izu7qza6BaIsyzwHXOk09x240sKMA6xswc4n8mi2m2d5cprtl+MOU4flgAz6WJEl7gOGD9owKS06WZByJHQlH/Ke5sGp/+VOY/YWSQZi257+GUQ7ClsCYSiIK8In/weZk4FILAYa7OZl+caIDk9bD/ZdFw1I3M+E4QC5YcQJBANiL91MRvs/RIwkoLC8JWphUiLOXgnUeZckYj0CPQ5hd5tVhJcBKSqGAd3RxqX0M6I4Eqzb+J16GrsCXwnlVnkcCQQDPJoDyuUue7B0q4toKsDFaIzDf/0/p0+Qss39r9USNJtt//NVpHSpfRiRmPrdeybQ1/5VYVmdA/rGGAXrD9m15AkEAjXIfgys8MBKzh++trKu3eXj+MhDtLgNFCS35pHnv9T6g4RAr0Ia2aPe5D16PDxe3b8ys6abpoFzpGPQIG6lJUQJAGNQFmpII9UhZip1cAvHxSFt1bTOdsWn7LDxrZlYkXEKvBl0YexvKy1aN4E9eDRdh6SL0FH1urMSaJHSi8T/lCQJAE+eXAGcNBSqsxU0l6ERxe25DYXOzlJ/zXh1kG8yYR9tVKVYVxqlGn6Mgsg10ae5Z07/3Eb+kUTRiYwmNb1FNfQ==";
    
    
    //--------------------
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [dict  valueForKey:@"order_no"];
    order.productName = [dict valueForKey:@"order_name"];
    order.productDescription =[dict valueForKey:@"order_description"];
    order.amount = [dict valueForKey:@"order_price"];
    order.notifyURL =  @"http://101.201.197.202:8080/appserver/chezhu/notifyForZhifubao.do"; //回调URL
    
    //下面的参数是固定的，不需要改变
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
        DLog(@"支付宝SB:%@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            DLog(@"reslut-- = %@",[resultDic description]);
            if ([[resultDic valueForKey:@"resultStatus"] intValue] == 9000) {
                success(resultDic);
            }
            else
            {
                fail(resultDic,nil);
            }
        }];
    }
}

@end
