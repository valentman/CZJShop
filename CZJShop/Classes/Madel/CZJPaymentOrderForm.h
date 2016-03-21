//
//  CZJPaymentOrderForm.h
//  CZJShop
//
//  Created by Joe.Pen on 3/14/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJPaymentOrderForm : NSObject
@property (nonatomic, strong) NSString* order_no;
@property (nonatomic, strong) NSString* order_name;
@property (nonatomic, strong) NSString* order_description;
@property (nonatomic, strong) NSString* order_price;
@end
