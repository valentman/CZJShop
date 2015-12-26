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

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self  = [super init])
    {
        _shoppingCartList = [NSMutableArray array];
        _shoppingCouponsList = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (void)setNewShoppingCartDictionary:(NSDictionary*)dict
{
    [_shoppingCartList removeAllObjects];
    [self appendNewShoppingCartData:dict];
}


- (void)appendNewShoppingCartData:(NSDictionary*)dict
{
    NSArray* tmpAry = [dict valueForKey:@"msg"];
    for (NSDictionary* tmpdict in tmpAry) {
        CZJShoppingCartInfoForm* form = [[CZJShoppingCartInfoForm alloc]initWithDictionary:tmpdict];
        [_shoppingCartList addObject:form];
    }
}

- (void)setNewCouponsDictionary:(NSDictionary*)dict
{
    [_shoppingCouponsList removeAllObjects];
    NSArray* tmpAry = [dict valueForKey:@"msg"];
    for (NSDictionary* tmpdict in tmpAry) {
        CZJShoppingCouponsForm* form = [[CZJShoppingCouponsForm alloc]initWithDictionary:tmpdict];
        [_shoppingCouponsList addObject:form];
    }
}

@end



//---------------------购物车列表信息---------------------

@implementation CZJShoppingCartInfoForm
@synthesize storeName = _storeName;
@synthesize items = _items;
@synthesize storeId = _storeId;
@synthesize selfFlag = _selfFlag;
@synthesize hasCoupon = _hasCoupon;


- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self  = [super init])
    {
        self.items = [NSMutableArray array];
        self.storeName = [dict valueForKey:@"storeName"];
        NSArray* goodsDict = [dict valueForKey:@"items"];
        for (NSDictionary* dict in goodsDict) {
            CZJShoppingGoodsInfoForm* form = [[CZJShoppingGoodsInfoForm alloc]initWithDictionary:dict];
            [self.items addObject:form];
        }
        self.storeId = [dict valueForKey:@"storeId"];
        self.selfFlag = [[dict valueForKey:@"selfFlag"] boolValue];
        self.hasCoupon = [[dict valueForKey:@"hasCoupon"] boolValue];
        self.isSelect = YES;
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

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self  = [super init])
    {
        self.itemName = [dict valueForKey:@"itemName"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.itemImg = [dict valueForKey:@"itemImg"];
        self.off = [dict valueForKey:@"off"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        self.itemCount = [dict valueForKey:@"itemCount"];
        self.itemSku = [dict valueForKey:@"itemSku"];
        self.itemCode = [dict valueForKey:@"itemCode"];
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

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self  = [super init])
    {
        self.validStartTime = [dict valueForKey:@"validStartTime"];
        self.storeName = [dict valueForKey:@"storeName"];
        self.validServiceId = [dict valueForKey:@"validServiceId"];
        self.taked = [dict valueForKey:@"taked"];
        self.name = [dict valueForKey:@"name"];
        self.value = [dict valueForKey:@"value"];
        self.validEndTime = [dict valueForKey:@"validEndTime"];
        self.couponId = [dict valueForKey:@"couponId"];
        self.type = [dict valueForKey:@"type"];
        self.validMoney = [dict valueForKey:@"validMoney"];
        self.storeId = [dict valueForKey:@"storeId"];
        return self;
    }
    return nil;
}
@end