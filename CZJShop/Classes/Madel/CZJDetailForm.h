//
//  CZJStoreServiceDetailForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CZJStoreInfoForm;
@class CZJServiceDetail;
@class CZJDetailEvalInfo;
@class CZJGoodsDetail;

@interface CZJDetailForm : NSObject
{
    NSMutableArray* _recommendServiceForms;         //推荐服务列表
    NSMutableArray* _couponForms;                   //领券列表
    CZJStoreInfoForm* _storeInfo;                   //服务门店信息
    CZJDetailEvalInfo* _evalutionInfo;              //服务评价简介
    CZJGoodsDetail* _goodsDetail;                   //商品详情信息
    CZJServiceDetail* _serviceDetail;               //服务详情信息
}
@property(nonatomic, strong) CZJServiceDetail* serviceDetail;
@property(nonatomic, strong) CZJGoodsDetail* goodsDetail;
@property(nonatomic, strong) CZJStoreInfoForm* storeInfo;
@property(nonatomic, strong) CZJDetailEvalInfo* evalutionInfo;
@property(nonatomic, strong) NSMutableArray* couponForms;
@property(nonatomic, strong) NSMutableArray* recommendServiceForms;
@property(nonatomic, strong) NSString* purchaseCount;

- (id)initWithDictionary:(NSDictionary*)dict WithType:(CZJDetailType)type;
- (void)setNewDictionary:(NSDictionary*)dict WithType:(CZJDetailType)type;
- (void)resetData;
@end

//---------------------券信息---------------------
@interface CZJCouponForm : NSObject
@property(nonatomic, strong) NSString* value;
@property(nonatomic, strong) NSString* validMoney;
@property(nonatomic, strong) NSString* couponId;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

//---------------------门店信息---------------------
@interface CZJStoreInfoForm : NSObject
@property(nonatomic, strong) NSString* storeAddr;
@property(nonatomic, strong) NSString* logo;
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, strong) NSString* attentionCount;
@property(nonatomic, assign) BOOL attentionFlag;
@property(nonatomic, strong) NSString* callCenterCount;
@property(nonatomic, strong) NSString* serviceCount;
@property(nonatomic, strong) NSString* goodsCount;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* callCenterType;

- (id)initWithDictionary:(NSDictionary*)dict;
@end


//--------------------详情页面评价简介信息---------------------
@interface CZJDetailEvalInfo : NSObject
@property(nonatomic, strong) NSString* poorCount;
@property(nonatomic, strong) NSMutableArray* evalList;
@property(nonatomic, strong) NSString* goodCount;
@property(nonatomic, strong) NSString* goodRate;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* hasImgCount;
@property(nonatomic, strong) NSString* normalCount;

- (id)initWithDictionary:(NSDictionary*)dict;
@end


//---------------------评价详情页评价信息---------------------
@interface CZJEvalutionsForm : NSObject
@property(nonatomic, strong) NSString* evalutionId;
@property(nonatomic, strong) NSMutableArray* imgs;
@property(nonatomic, strong) NSString* evalStar;
@property(nonatomic, strong) NSString* evalTime;
@property(nonatomic, strong) NSString* evalDesc;
@property(nonatomic, strong) NSString* evalHead;
@property(nonatomic, strong) NSString* evalName;

- (id)initWithDictionary:(NSDictionary*)dict;

@end


//---------------------服务详情信息---------------------
@interface CZJServiceDetail : NSObject
@property(nonatomic, strong) NSMutableArray* imgs;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* costPrice;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* originalPrice;
@property(nonatomic, strong) NSString* counterKey;
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, assign) BOOL goHouseFlag;
@property(nonatomic, assign) BOOL attentionFlag;
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) NSString* itemCode;

- (id)initWithDictionary:(NSDictionary*)dict;

@end


//---------------------商品详情信息---------------------
@class CZJGoodsSKU;
@interface CZJGoodsDetail : NSObject
@property(nonatomic, strong) NSMutableArray* imgs;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* costPrice;
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, strong) NSString* setupFlag;
@property(nonatomic, assign) BOOL goHouseFlag;
@property(nonatomic, assign) BOOL attentionFlag;
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) CZJGoodsSKU* sku;
@property(nonatomic, strong) NSString* vendorId;
@property(nonatomic, strong) NSString* deliveryFlag;
@property(nonatomic, strong) NSString* transportPrice;
@property(nonatomic, strong) NSString* originalPrice;
@property(nonatomic, strong) NSString* counterKey;
@property(nonatomic, strong) NSString* skillFlag;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* skillPrice;
@property(nonatomic, strong) NSString* typeId;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* skillEndTime;
@property(nonatomic, assign) BOOL selfFlag;
@property(nonatomic, strong) NSString* itemCode;

- (id)initWithDictionary:(NSDictionary*)dict;

@end


//---------------------商品SKU信息---------------------
@interface CZJGoodsSKU : NSObject
@property(nonatomic, strong) NSString* skuPrice;
@property(nonatomic, strong) NSString* skuStock;
@property(nonatomic, strong) NSString* skuName;
@property(nonatomic, strong) NSString* skuCode;
@property(nonatomic, strong) NSString* skuImg;
@property(nonatomic, strong) NSString* skuValueIds;
@property(nonatomic, strong) NSString* skuValues;

- (id)initWithDictionary:(NSDictionary*)dict;
@end
