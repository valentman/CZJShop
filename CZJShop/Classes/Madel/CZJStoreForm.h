//
//  CZJStoreForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/3/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

/*****************************门店数据******************************/
@interface CZJStoreForm : NSObject
{
    NSMutableArray* _storeListForms;
    NSMutableArray* _storeServiceListForms;
    NSMutableArray* _provinceForms;
    NSMutableArray* _cityForms;
}
@property (nonatomic, strong) NSMutableArray* storeListForms;
@property (nonatomic, strong) NSMutableArray* storeServiceListForms;
@property (nonatomic, strong) NSMutableArray* provinceForms;
@property (nonatomic, strong) NSMutableArray* cityForms;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)setNewStoreListDataWithDictionary:(NSDictionary*)dict;
- (void)appendStoreListData:(NSDictionary*)dict;
- (void)setNewStoreServiceListDataWithDictionary:(NSDictionary*)dict;
- (void)appendStoreServiceListData:(NSDictionary*)dict;
- (void)setNewProvinceDataWithDictionary:(NSDictionary*)dict;
- (NSString*)getCityIDWithCityName:(NSString*)cityname;
@end


//-------------------------附近门店信息------------------------------
@interface CZJNearbyStoreForm : NSObject
@property(nonatomic, strong) NSString* distance;
@property(nonatomic, strong) NSString* distanceMeter;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* openingHours;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* homeImg;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* goodRate;
@property(nonatomic, strong) NSString* star;
@property(nonatomic, strong) NSString* addr;
@property(nonatomic, strong) NSString* lng;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSString* lat;
@property(nonatomic, strong) NSString* evaluationAvg;
@property(nonatomic, strong) NSString* setupCount;
@property(nonatomic, strong) NSString* setupPrice;

- (id)initWithDictionary:(NSDictionary*)dict;
@end


//-------------------------附近门店服务列表信息------------------------------
@interface CZJNearbyStoreServiceListForm : NSObject
@property(nonatomic, strong) NSString* addr;
@property(nonatomic, strong) NSString* distance;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* goodsCount;
@property(nonatomic, strong) NSString* homeImg;
@property(nonatomic, assign) BOOL moreFlag;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* goodRate;
@property(nonatomic, strong) NSString* star;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, strong) NSMutableArray* items;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

@interface CZJStoreServiceForm : NSObject
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* goHouseFlag;
@property(nonatomic, strong) NSString* goStoreFlag;
@property(nonatomic, strong) NSString* goodEvalRate;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* itemType;
@property(nonatomic, strong) NSString* originalPrice;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* skillFlag;
@property(nonatomic, strong) NSString* skillPrice;
@property(nonatomic, strong) NSString* storeItemPid;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

