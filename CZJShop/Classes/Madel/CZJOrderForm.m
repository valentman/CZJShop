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

- (id) initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.stores = [NSMutableArray array];
        self.cardMoney = [dict valueForKey:@"cardMoney"];
        self.needAddr = [dict valueForKey:@"needAddr"];
        self.needCoupon = [dict valueForKey:@"needCoupon"];
        self.needRedpacket = [dict valueForKey:@"needRedpacket"];
        self.redpacket = [dict valueForKey:@"redpacket"];
        NSArray* tmpAry = [dict valueForKey:@"stores"];
        for (NSDictionary* storeDict in tmpAry)
        {
            CZJOrderStoreForm* form = [[CZJOrderStoreForm alloc]initWithDictionary:storeDict];
            [self.stores addObject:form];
        }
        return self;
    }
    return nil;
}
@end


@implementation CZJOrderStoreForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJOrderGoodsForm"};
}
- (id) initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.gifts = [NSMutableArray array];
        self.items = [NSMutableArray array];

        self.fullCutPrice = [dict valueForKey:@"fullCutPrice"] ? [dict valueForKey:@"fullCutPrice"] : @"0";
        self.storeId = [dict valueForKey:@"storeId"] ? [dict valueForKey:@"storeId"] : @"";
        self.storeName = [dict valueForKey:@"storeName"] ? [dict valueForKey:@"storeName"] : @"";
        self.transportPrice = [dict valueForKey:@"transportPrice"] ? [dict valueForKey:@"transportPrice"] : @"0";
        self.note = [dict valueForKey:@"note"] ? [dict valueForKey:@"note"] : @"";
        self.companyId = [dict valueForKey:@"companyId"] ? [dict valueForKey:@"companyId"] : @"";
        self.couponPrice = [dict valueForKey:@"couponPrice"] ? [dict valueForKey:@"couponPrice"] : @"0";
        self.chezhuCouponPid = [dict valueForKey:@"chezhuCouponPid"] ? [dict valueForKey:@"chezhuCouponPid"] : @"0";
        self.orderPrice = [dict valueForKey:@"orderPrice"] ? [dict valueForKey:@"orderPrice"] : @"0";
        self.orderMoney = [dict valueForKey:@"orderMoney"] ? [dict valueForKey:@"orderMoney"] : @"0";
        self.totalSetupPrice = [dict valueForKey:@"totalSetupPrice"] ? [dict valueForKey:@"totalSetupPrice"] : @"0";
        self.selfFlag = [dict valueForKey:@"selfFlag"] ? [dict valueForKey:@"selfFlag"] : @"";
        self.hasCoupon = [dict valueForKey:@"hasCoupon"] ? [dict valueForKey:@"hasCoupon"] : @"";
        self.gifts = [dict valueForKey:@"gifts"];
        NSArray* itemsAry = [dict valueForKey:@"items"];
        for (NSDictionary* goodDict in itemsAry)
        {
            [self.items addObject:[CZJOrderGoodsForm objectWithKeyValues:goodDict]];
        }
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
        self.activityId =  @"0";
        self.costPrice =  @"0";
        self.currentPrice =  @"0";
        self.itemCode = @"0";
        self.itemCount = @"0";
        self.itemImg = @"";
        self.itemName = @"";
        self.itemSku =  @"";
        self.itemType = @"0";
        self.storeItemPid = @"0";
        self.typeId = @"";
        self.vendorId = @"";
        self.setupStoreName = @"";
        self.selectdSetupStoreName = @"";
        self.setupStoreId = @"0";
        self.returnStatus = @"0";
        self.setupPrice = @"0";
        self.orderItemPid = @"0";
        self.setmenuFlag = false;
        self.setupFlag = false;
        self.off = false;
        self.counterKey = @"";
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
    return @{@"items" : @"CZJOrderGoodsForm"};
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