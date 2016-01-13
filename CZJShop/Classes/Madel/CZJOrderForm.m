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

@implementation CZJOrderStoreForm
@synthesize fullCutPrice = _fullCutPrice;
@synthesize gifts = _gifts;
@synthesize items = _items;
@synthesize selfFlag = _selfFlag;
@synthesize storeId = _storeId;
@synthesize storeName = _storeName;
@synthesize transportPrice = _transportPrice;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.items = [NSMutableArray array];
        self.gifts = [NSMutableArray array];
        self.fullCutPrice = [dict valueForKey:@"fullCutPrice"];
        self.selfFlag = [[dict valueForKey:@"selfFlag"] boolValue];
        self.storeId = [dict valueForKey:@"storeId"];
        self.storeName = [dict valueForKey:@"storeName"];
        self.transportPrice = [dict valueForKey:@"transportPrice"];
        self.gifts = [dict valueForKey:@"gifts"];
        NSArray* itemTmpAry = [dict valueForKey:@"items"];
        for (NSDictionary* dict in itemTmpAry)
        {
            CZJOrderGoodsForm* form = [[CZJOrderGoodsForm alloc]initWithDictionary:dict];
            [self.items addObject:form];
        }
        self.leaveMessage = @"";
        return self;
    }
    return nil;
}
@end

@implementation CZJOrderGoodsForm
- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.activityId = [dict valueForKey:@"activityId"];
        self.costPrice = [dict valueForKey:@"costPrice"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        self.itemCode = [dict valueForKey:@"itemCode"];
        self.itemCount = [dict valueForKey:@"itemCount"];
        self.itemImg = [dict valueForKey:@"itemImg"];
        self.itemName = [dict valueForKey:@"itemName"];
        self.itemSku = [dict valueForKey:@"itemSku"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.setmenuFlag = [[dict valueForKey:@"setmenuFlag"]boolValue];
        self.setupFlag = [[dict valueForKey:@"setupFlag"]boolValue];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.typeId = [dict valueForKey:@"typeId"];
        self.vendorId = [dict valueForKey:@"vendorId"];
        self.selectdSetupStoreName = @"选择安装门店";
        return self;
    }
    return nil;
}
@end


@implementation CZJOrderTypeForm
@synthesize orderTypeImg = _orderTypeImg;
@synthesize orderTypeName = _orderTypeName;
@synthesize isSelect = _isSelect;
@end

@implementation CZJAddrForm
@synthesize receiver = _receiver;
@synthesize province = _province;
@synthesize city = _city;
@synthesize county = _county;
@synthesize dftFlag = _dftFlag;
@synthesize isSelected = _isSelected;
@synthesize mobile = _mobile;
@synthesize addr = _addr;
@synthesize addrId = _addrId;
@end

@implementation CZJOrderStoreCouponsForm
- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.coupons = [NSMutableArray array];
        self.storeId = [dict valueForKey:@"storeId"];
        self.storeName = [dict valueForKey:@"storeName"];
        self.selectedCouponId = @"";
        NSArray* coupons = [dict valueForKey:@"coupons"];
        for (NSDictionary* dict in coupons)
        {
            CZJShoppingCouponsForm* form = [[CZJShoppingCouponsForm alloc]initWithDictionary:dict];
            [self.coupons addObject:form];
        }
        return self;
    }
    return nil;
}
@end