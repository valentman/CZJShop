//
//  CZJStoreDetailForm.h
//  CZJShop
//
//  Created by Joe.Pen on 1/15/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJStoreDetailForm : NSObject
@property(strong, nonatomic)NSString* attentionCount;
@property(assign)BOOL attentionFlag;
@property(strong, nonatomic)NSString* cityId;
@property(strong, nonatomic)NSString* companyId;
@property(strong, nonatomic)NSString* contactAccount;
@property(strong, nonatomic)NSString* contactName;
@property(strong, nonatomic)NSString* contactType;
@property(strong, nonatomic)NSString* deliveryScore;
@property(strong, nonatomic)NSString* descScore;
@property(strong, nonatomic)NSString* environmentScore;
@property(strong, nonatomic)NSString* goodsCount;
@property(strong, nonatomic)NSString* hotline;
@property(strong, nonatomic)NSString* lat;
@property(strong, nonatomic)NSString* lng;
@property(strong, nonatomic)NSString* promotionCount;
@property(strong, nonatomic)NSString* serviceCount;
@property(strong, nonatomic)NSString* serviceScore;
@property(strong, nonatomic)NSString* setmenuCount;
@property(strong, nonatomic)NSString* storeAddr;
@property(strong, nonatomic)NSString* storeId;
@property(strong, nonatomic)NSString* storeName;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

//-----------------------门店详情活动-----------------------
@interface CZJStoreDetailActivityForm : NSObject
@property(nonatomic, strong) NSString* activityId;
@property(nonatomic, strong) NSString* img;
@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) NSString* title;

- (id)initWithDictionary:(NSDictionary*)dictionary;
@end

//-----------------------门店详情广告栏-----------------------
@interface CZJStoreDetailBannerForm : NSObject
@property(nonatomic, strong) NSString* bannerID;
@property(nonatomic, strong) NSString* img;
@property(nonatomic, strong) NSString* type;
@property(nonatomic, strong) NSString* title;

- (id)initWithDictionary:(NSDictionary*)dictionary;
@end

//-----------------------门店商品类型、服务类型-----------------------
@interface CZJStoreDetailTypesForm : NSObject
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* typeId;
- (id)initWithDictionary:(NSDictionary*)dictionary;
@end

//-----------------------服务或商品-----------------------
@interface CZJSToreDetailGoodsAndServiceForm : NSObject
@property(nonatomic, strong)NSString* originalPrice;
@property(nonatomic, strong)NSString* storeItemPid;
@property(nonatomic, strong)NSString* itemType;
@property(nonatomic, strong)NSString* itemName;
@property(nonatomic, strong)NSString* itemImg;
@property(nonatomic, strong)NSString* currentPrice;

- (id)initWithDictionary:(NSDictionary*)dict;
@end