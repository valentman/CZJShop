//
//  CZJOrderForm.h
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface CZJOrderStoreForm : NSObject
@property(strong, nonatomic)NSString* fullCutPrice;
@property(strong, nonatomic)NSMutableArray* gifts;
@property(strong, nonatomic)NSMutableArray* items;
@property(assign)BOOL selfFlag;
@property(strong, nonatomic)NSString* storeId;
@property(strong, nonatomic)NSString* storeName;
@property(strong, nonatomic)NSString* transportPrice;
@property(strong, nonatomic)NSString* leaveMessage;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

@interface CZJOrderGoodsForm : NSObject
@property(strong, nonatomic)NSString* activityId;
@property(strong, nonatomic)NSString* costPrice;
@property(strong, nonatomic)NSString* currentPrice;
@property(strong, nonatomic)NSString* itemCode;
@property(strong, nonatomic)NSString* itemCount;
@property(strong, nonatomic)NSString* itemImg;
@property(strong, nonatomic)NSString* itemName;
@property(strong, nonatomic)NSString* itemSku;
@property(strong, nonatomic)NSString* itemType;
@property(strong, nonatomic)NSString* storeItemPid;
@property(assign)BOOL setupFlag;
@property(assign)BOOL setmenuFlag;
@property(strong, nonatomic)NSString* typeId;
@property(strong, nonatomic)NSString* vendorId;
@property(strong, nonatomic)NSString* selectdSetupStoreName;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

@interface CZJOrderTypeForm : NSObject
@property(strong, nonatomic)NSString* orderTypeName;
@property(strong, nonatomic)NSString* orderTypeImg;
@property(assign) BOOL isSelect;
@end


@interface CZJAddrForm : NSObject
@property (strong, nonatomic)NSString* receiver;
@property (strong, nonatomic)NSString* province;
@property (strong, nonatomic)NSString* city;
@property (strong, nonatomic)NSString* county;
@property (assign) BOOL dftFlag;
@property (assign) BOOL isSelected;
@property (strong, nonatomic)NSString* mobile;
@property (strong, nonatomic)NSString* addr;
@property (strong, nonatomic)NSString* addrId;
@end

@interface CZJOrderStoreCouponsForm : NSObject
@property (strong, nonatomic)NSMutableArray* coupons;
@property (strong, nonatomic)NSString* storeId;
@property (strong, nonatomic)NSString* storeName;
@property (strong, nonatomic)NSString* selectedCouponId;
@property (assign) BOOL isSelfFlag;
- (id)initWithDictionary:(NSDictionary*)dict;

@end
