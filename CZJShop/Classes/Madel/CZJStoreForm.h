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
    NSMutableArray* _provinceForms;
    NSMutableArray* _cityForms;
}
@property (nonatomic, strong) NSMutableArray* storeListForms;
@property (nonatomic, strong) NSMutableArray* provinceForms;
@property (nonatomic, strong) NSMutableArray* cityForms;

- (id)init;
- (void)setNewStoreListDataWithDictionary:(NSDictionary*)dict;
- (void)appendStoreListData:(NSDictionary*)dict;
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
@property(nonatomic, strong) NSString* type;
@property(nonatomic, assign) BOOL couponFlag;
@property(nonatomic, assign) BOOL promotionFlag;
@end


//-------------------------附近服务列表信息------------------------------
@interface CZJStoreServiceForm : NSObject
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) NSString* distance;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* goodEvalRate;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* itemType;
@property(nonatomic, strong) NSString* originalPrice;
@property(nonatomic, strong) NSString* purchaseCount;
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, strong) NSString* storeName;
@property(nonatomic, assign) BOOL promotionFlag;
@property(nonatomic, assign) BOOL newlyFlag;
@property(nonatomic, assign) BOOL goHouseFlag;
@property(nonatomic, assign) BOOL goStoreFlag;

@end

