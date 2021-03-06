//
//  CZJShoppingCartForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJShoppingCartForm : NSObject
{
    NSMutableArray* _shoppingCartList;
    NSMutableArray* _shoppingCouponsList;
}
@property(nonatomic, strong)NSMutableArray* shoppingCartList;
@property(nonatomic, strong)NSMutableArray* shoppingCouponsList;

- (id)init;
- (void)setNewCouponsDictionary:(NSDictionary*)dict;
@end



//---------------------购物车列表信息---------------------
@interface CZJShoppingCartInfoForm : NSObject
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, strong) NSMutableArray* items;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* companyId;
@property(assign) BOOL selfFlag;
@property(assign) BOOL hasCoupon;
@property(assign) BOOL isSelect;
@property(assign) BOOL isDeleteSelect;

- (id)init;
@end


//---------------------购物车商品信息---------------------
@interface CZJShoppingGoodsInfoForm : NSObject
@property(nonatomic, strong) NSString*itemName;
@property(nonatomic, strong) NSString*storeItemPid;
@property(nonatomic, strong) NSString*itemType;
@property(nonatomic, strong) NSString*itemImg;
@property(nonatomic, strong) NSString*currentPrice;
@property(nonatomic, strong) NSString*itemCount;
@property(nonatomic, strong) NSString*itemSku;
@property(nonatomic, strong) NSString*itemCode;
@property(nonatomic, strong) NSString*typeId;
@property(assign) BOOL isSelect;
@property(assign) BOOL isDeleteSelect;
@property(assign) BOOL off;

- (id)init;
@end

//---------------------购物券信息---------------------
@interface CZJShoppingCouponsForm : NSObject
@property(nonatomic, strong) NSString* validServiceName;
@property(nonatomic, strong) NSString* validStartTime;
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, strong) NSString* validServiceId;
@property(assign) BOOL taked;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* value;
@property(nonatomic, strong) NSString* validEndTime;
@property(nonatomic, strong) NSString* couponId;
@property(nonatomic, strong) NSString* type;
@property(nonatomic, strong) NSString* validMoney;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* chezhuCouponPid;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

//---------------------提交订单信息---------------------
@interface CZJSettleOrderForm : NSObject
@property(nonatomic, strong) NSString* companyId;
@property(nonatomic, strong) NSString* selfFlag;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, strong) NSArray* items;
@end

//-----------------提交订单中得商品信息-------------------
@interface CZJsettleOrderGoodItemForm : NSObject
@property(nonatomic, strong) NSString* activityId;
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, strong) NSString* itemCode;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* itemSku;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* costPrice;
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) NSString* itemType;
@property(nonatomic, strong) NSString* itemCount;
@property(nonatomic, strong) NSString* setmenuFlag;
@property(nonatomic, strong) NSString* typeId;
@end
