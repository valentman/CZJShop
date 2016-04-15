//
//  CZJOrderForm.m
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZJOrderForm.h"
#import "CZJShoppingCartForm.h"

@implementation CZJOrderForm

+ (NSDictionary *)objectClassInArray{
    return @{@"stores" : @"CZJOrderStoreForm"};
}
@end


@implementation CZJOrderStoreForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJOrderGoodsForm",
             @"gifts" : @"CZJShoppingGoodsInfoForm"};
}
- (id) init
{
    if (self = [super init])
    {
        self.fullCutPrice =  @"0";
        self.storeId =  @"";
        self.storeName =  @"";
        self.transportPrice =  @"0";
        self.note = @"";
        self.companyId =  @"0";
        self.couponPrice =  @"0";
        self.chezhuCouponPid =  @"0";
        self.orderPrice = @"0";
        self.orderMoney =  @"0";
        self.totalSetupPrice =  @"0";
        self.selfFlag = @"0";
        self.hasCoupon = @"0";
        return self;
    }
    return nil;
}
@end

@implementation CZJOrderListForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJOrderGoodsForm"};
}

@end

@implementation CZJOrderGoodsForm
- (id) init
{
    if (self = [super init])
    {
        self.costPrice =  @"0";
        self.currentPrice =  @"0";
        self.setupPrice = @"0";
        self.setmenuFlag = false;
        self.setupFlag = false;
        self.off = false;
        return self;
    }
    return nil;
}
@end


@implementation CZJOrderTypeForm
@end


@implementation CZJAddrForm
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"addrId" : @"id",
             };
}
@end


@implementation CZJOrderStoreCouponsForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"coupons" : @"CZJShoppingCouponsForm"};
}
@end


@implementation CZJOrderDetailForm

+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJOrderGoodsForm",
             @"gifts" : @"CZJShoppingGoodsInfoForm"};
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.activityId = @"";
        self.benefitMoney = @"";
        self.companyId = @"";
        self.couponPrice = @"";
        self.createTime = @"";
        self.evaluated = false;
        self.fullCutPrice = @"";
        self.items = [NSMutableArray array];
        self.note = @"";
        self.orderMoney = @"";
        self.orderNo = @"";
        self.orderPoint = @"";
        self.orderPrice = @"";
        self.paidFlag = false;
        self.receiver = nil;
        self.setupPrice = @"";
        self.status = @"";
        self.storeId = @"";
        self.storeName = @"";
        self.timeOver = @"";
        self.transportPrice = @"";
        self.type = @"";
        return self;
    }
    return nil;
}

@end


@implementation CZJCarDetailForm

@end

@implementation CZJCarCheckItemForm

@end

@implementation CZJCarCheckItemsForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJCarCheckItemForm"};
}
@end

@implementation CZJCarCheckForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"checks" : @"CZJCarCheckItemsForm"};
}
@end

@implementation CZJReturnedOrderListForm
@end

@implementation CZJReturnedOrderDetailForm
@end

@implementation CZJSubmitReturnForm
@end