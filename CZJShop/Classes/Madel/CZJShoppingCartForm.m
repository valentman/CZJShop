//
//  CZJShoppingCartForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJShoppingCartForm.h"

@implementation CZJShoppingCartForm
@synthesize shoppingCartList = _shoppingCartList;
@synthesize shoppingCouponsList = _shoppingCouponsList;

- (id)init
{
    if (self  = [super init])
    {
        _shoppingCartList = [NSMutableArray array];
        _shoppingCouponsList = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (void)setNewCouponsDictionary:(NSDictionary*)dict
{
    [_shoppingCouponsList removeAllObjects];
    NSArray* tmpAry = [dict valueForKey:@"msg"];
    DLog(@"%@",[dict description]);
    for (NSDictionary* tmpdict in tmpAry) {
        CZJShoppingCouponsForm* form = [[CZJShoppingCouponsForm alloc]initWithDictionary:tmpdict];
        [_shoppingCouponsList addObject:form];
    }
}

@end



//---------------------购物车列表信息---------------------

@implementation CZJShoppingCartInfoForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJShoppingGoodsInfoForm"};
}

- (id)init
{
    if (self  = [super init])
    {
        self.isSelect = YES;
        self.isDeleteSelect = NO;
        return self;
    }
    return nil;
}
@end




//---------------------购物车商品信息---------------------
@implementation CZJShoppingGoodsInfoForm
@synthesize itemName = _itemName;
@synthesize storeItemPid = _storeItemPid;
@synthesize itemType = _itemType;
@synthesize itemImg = _itemImg;
@synthesize off = _off;
@synthesize currentPrice = _currentPrice;
@synthesize itemCount = _itemCount;
@synthesize itemSku = _itemSku;
@synthesize itemCode = _itemCode;
@synthesize isSelect = _isSelect;
@synthesize isDeleteSelect = _isDeleteSelect;

- (id)init
{
    if (self  = [super init])
    {
        self.isSelect = NO;
        self.isDeleteSelect = NO;
        self.off = NO;
        return self;
    }
    return nil;
}
@end


@implementation CZJShoppingCouponsForm
@synthesize validStartTime = _validStartTime;
@synthesize storeName = _storeName;
@synthesize validServiceId = _validServiceId;
@synthesize taked = _taked;
@synthesize name = _name;
@synthesize value = _value;
@synthesize validEndTime = _validEndTime;
@synthesize couponId = _couponId;
@synthesize type = _type;
@synthesize validMoney = _validMoney;
@synthesize storeId = _storeId;
@synthesize chezhuCouponPid = _chezhuCouponPid;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self  = [super init])
    {
        self.validStartTime = [dict valueForKey:@"validStartTime"];
        self.storeName = [dict valueForKey:@"storeName"];
        self.validServiceId = [dict valueForKey:@"validServiceId"];
        self.taked = [[dict valueForKey:@"taked"] boolValue];
        self.name = [dict valueForKey:@"name"];
        self.value = [dict valueForKey:@"value"];
        self.validEndTime = [dict valueForKey:@"validEndTime"];
        self.couponId = [dict valueForKey:@"couponId"];
        self.type = [dict valueForKey:@"type"];
        self.validMoney = [dict valueForKey:@"validMoney"];
        self.storeId = [dict valueForKey:@"storeId"];
        self.chezhuCouponPid = [dict valueForKey:@"chezhuCouponPid"];
        return self;
    }
    return nil;
}
@end


@implementation CZJSettleOrderForm
+(NSDictionary*)objectClassInArray
{
    return @{@"items" : @"CZJsettleOrderGoodItemForm"};
}
@end


@implementation CZJsettleOrderGoodItemForm
@end
