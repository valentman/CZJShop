//
//  CZJPaymentManager.h
//  CZJShop
//
//  Created by Joe.Pen on 3/14/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJPaymentManager : NSObject
singleton_interface(CZJPaymentManager);

- (void)weixinPay:(CZJPaymentOrderForm*)_orderDict;
@end
