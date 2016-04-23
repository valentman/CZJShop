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

@implementation CZJLevelSku
+ (NSDictionary*)objectClassInArray
{
    return @{@"twoSkus" : @"CZJLevelSku"};
}
@end

@implementation CZJGoodsDetail
@end

@implementation CZJStoreInfoForm
@end

@implementation CZJGoodsDetailForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"coupons" : @"CZJShoppingCouponsForm",
             @"promotions" : @"CZJPromotionItemForm"};
}
@end

@implementation CZJPromotionItemForm
@end

@implementation CZJPromotionDetailForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"gifts" : @"CZJGoodsDetail",
             @"items" : @"CZJGoodsDetail"};
}
@end
