//
//  CZJGoodsDetailForm.h
//  CZJShop
//
//  Created by Joe.Pen on 2/20/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CZJDetailEvalInfo;
//---------------------商品SKU信息---------------------
@interface CZJGoodsSKU : NSObject
@property(nonatomic, strong) NSString* skuPrice;
@property(nonatomic, strong) NSString* skuStock;
@property(nonatomic, strong) NSString* skuName;
@property(nonatomic, strong) NSString* skuCode;
@property(nonatomic, strong) NSString* skuImg;
@property(nonatomic, strong) NSString* skuValueIds;
@property(nonatomic, strong) NSString* skuValues;
@property(nonatomic, strong) NSString* storeItemPid;

@end

//---------------------商品信息---------------------
@interface CZJGoodsDetail : NSObject
@property(nonatomic, strong) NSMutableArray* imgs;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* costPrice;
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, strong) NSString* setupFlag;
@property(nonatomic, assign) BOOL goHouseFlag;
@property(nonatomic, assign) BOOL attentionFlag;
@property(nonatomic, assign) BOOL skillFlag;
@property(nonatomic, assign) BOOL selfFlag;
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) CZJGoodsSKU* sku;
@property(nonatomic, strong) NSString* vendorId;
@property(nonatomic, strong) NSString* deliveryFlag;
@property(nonatomic, strong) NSString* transportPrice;
@property(nonatomic, strong) NSString* originalPrice;
@property(nonatomic, strong) NSString* counterKey;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* skillPrice;
@property(nonatomic, strong) NSString* typeId;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* skillEndTime;
@property(nonatomic, strong) NSString* itemCode;
@property(nonatomic, strong) NSString* companyId;
@property(nonatomic, strong) NSString* buyType;
@property(nonatomic, strong) NSString* itemSku;
@property(nonatomic, strong) NSString* itemType;
@end

//---------------------门店信息---------------------
@interface CZJStoreInfoForm : NSObject
@property(nonatomic, strong) NSString* callCenterCount;
@property(nonatomic, strong) NSString* callCenterType;
@property(nonatomic, strong) NSString* attentionCount;
@property(nonatomic, assign) BOOL attentionFlag;
@property(nonatomic, strong) NSString* cityId;
@property(nonatomic, strong) NSString* companyId;
@property(nonatomic, strong) NSString* contactAccount;
@property(nonatomic, strong) NSString* contactName;
@property(nonatomic, strong) NSString* contactType;
@property(nonatomic, strong) NSString* goodsCount;
@property(nonatomic, strong) NSString* logo;
@property(nonatomic, strong) NSString* serviceCount;
@property(nonatomic, strong) NSString* storeAddr;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* storeName;
@end


//---------------------券信息---------------------
@interface CZJCouponForm : NSObject
@property(nonatomic, strong) NSString* validServiceName;
@property(nonatomic, strong) NSString* validStartTime;
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, strong) NSString* validServiceId;
@property(nonatomic, assign) BOOL taked;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* value;
@property(nonatomic, strong) NSString* validEndTime;
@property(nonatomic, strong) NSString* couponId;
@property(nonatomic, strong) NSString* type;
@property(nonatomic, strong) NSString* validMoney;
@property(nonatomic, strong) NSString* storeId;
@end

@interface CZJGoodsDetailForm : NSObject
@property (nonatomic, strong)CZJGoodsDetail* goods;
@property (nonatomic, strong)CZJStoreInfoForm* store;
@property (nonatomic, strong)CZJDetailEvalInfo* evals;
@property (nonatomic, strong)NSArray* coupons;
@property (nonatomic, strong)NSArray* promotions;
@end