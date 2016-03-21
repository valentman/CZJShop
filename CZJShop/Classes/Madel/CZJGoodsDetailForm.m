//
//  CZJGoodsDetailForm.m
//  CZJShop
//
//  Created by Joe.Pen on 2/20/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJGoodsDetailForm.h"

@implementation CZJGoodsSKU
@end

@implementation CZJGoodsDetail
@end

@implementation CZJStoreInfoForm
@end


@implementation CZJDetailEvalInfo
+ (NSDictionary *)objectClassInArray
{
    return @{@"evalList" : @"CZJEvalutionsForm"};
}
@end

@implementation CZJCouponForm
@end

@implementation CZJGoodsDetailForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"coupons" : @"CZJCouponForm"};
}
@end
