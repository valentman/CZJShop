//
//  CZJStoreForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/3/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJStoreForm.h"
#import "CZJProvinceForm.h"

@implementation CZJStoreForm
@synthesize storeListForms = _storeListForms;
@synthesize storeServiceListForms = _storeServiceListForms;
@synthesize provinceForms = _provinceForms;
@synthesize cityForms = _cityForms;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        
        return self;
    }
    return nil;
}

- (void)setNewStoreListDataWithDictionary:(NSDictionary*)dict
{
    if (_storeListForms)
    {
        [_storeListForms removeAllObjects];
    }
    else
    {
        _storeListForms = [NSMutableArray array];
    }
    [self appendStoreListData:dict];
}

- (void)appendStoreListData:(NSDictionary*)dict
{
    NSArray* storelist = [dict valueForKey:@"msg"];
    for (id obj in storelist )
    {
        CZJNearbyStoreForm* storelist =  [[CZJNearbyStoreForm alloc]initWithDictionary:obj];
        [_storeListForms addObject:storelist];
    }
}

- (void)setNewStoreServiceListDataWithDictionary:(NSDictionary*)dict
{
    if (_storeServiceListForms)
    {
        [_storeServiceListForms removeAllObjects];
    }
    else
    {
        _storeServiceListForms = [NSMutableArray array];
    }
    [self appendStoreServiceListData:dict];
}

- (void)appendStoreServiceListData:(NSDictionary*)dict
{
    NSArray* storelist = [dict valueForKey:@"msg"];
    for (id obj in storelist )
    {
        CZJNearbyStoreServiceListForm* storelist =  [[CZJNearbyStoreServiceListForm alloc]initWithDictionary:obj];
        [_storeServiceListForms addObject:storelist];
    }
}

- (void)setNewProvinceDataWithDictionary:(NSDictionary*)dict
{
    if (_provinceForms)
    {
        [_provinceForms removeAllObjects];
        [_cityForms removeAllObjects];
    }
    else
    {
        _provinceForms = [NSMutableArray array];
        _cityForms = [NSMutableArray array];
    }
    NSArray* provinces = [[dict valueForKey:@"msg"] valueForKey:@"provinces"];
    NSMutableArray* citys = [[[dict valueForKey:@"msg"] valueForKey:@"citys"] mutableCopy];
    
    for (id cityObj in citys)
    {
        NSString* cityProID = [cityObj valueForKey:@"provinceId"];
        CZJCitysForm* tmp_citys = [[CZJCitysForm alloc]initWithDictionary:cityObj];
        [_cityForms addObject:tmp_citys];
    }
    
    for (id proObj in provinces )
    {
        CZJProvinceForm* tmp_provinces = [[CZJProvinceForm alloc]initWithDictionary:proObj];
        NSString* currentProvID = [proObj valueForKey:@"provinceId"];
        for (id cityObj in citys)
        {
            NSString* cityProID = [cityObj valueForKey:@"provinceId"];
            CZJCitysForm* tmp_citys = [[CZJCitysForm alloc]initWithDictionary:cityObj];
            if ([currentProvID isEqualToString:@"0"])
            {
                [tmp_provinces.containCitys addObject:tmp_citys];
            }
            if ([currentProvID isEqualToString: cityProID]) {
                [tmp_provinces.containCitys addObject:tmp_citys];
            }
            
        }
        [_provinceForms addObject:tmp_provinces];
    }
}
- (NSString*)getCityIDWithCityName:(NSString*)cityname
{
    NSString* _cityId;
    for (CZJCitysForm* obj in _cityForms) {
        if ([obj.name isEqualToString:cityname]) {
            _cityId = obj.cityId;
            break;
        }
    }
    return _cityId;
}

@end


@implementation CZJNearbyStoreForm
@synthesize distance = _distance;
@synthesize purchaseCount = _purchaseCount;
@synthesize openingHours = _openingHours;
@synthesize name = _name;
@synthesize homeImg = _homeImg;
@synthesize evalCount = _evalCount;
@synthesize star = _star;
@synthesize addr = _addr;
@synthesize lng = _lng;
@synthesize storeId = _storeId;
@synthesize lat = _lat;

-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.distance = [dict valueForKey:@"distance"];
        
        if ([self.distance containsString:@"km"])
        {
            NSRange range = [self.distance rangeOfString:@"km"];
            NSString* kilometer = [self.distance substringToIndex:range.location];
            int distanc = [kilometer floatValue]*1000;
            self.distanceMeter = [NSString stringWithFormat:@"%d",distanc];
        }
        else
        {
            NSRange range = [self.distance rangeOfString:@"m"];
            self.distanceMeter = [self.distance substringToIndex:range.location];
        }
        
        
        self.purchaseCount = [NSString stringWithFormat:@"%@",[dict valueForKey:@"purchaseCount"]];
        self.openingHours = [dict valueForKey:@"openingHours"];
        self.name = [dict valueForKey:@"name"];
        self.homeImg = [dict valueForKey:@"homeImg"];
        self.evalCount = [NSString stringWithFormat:@"%@",[dict valueForKey:@"evalCount"]];
        int rate = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"star"]] floatValue] * 100 /5;
        self.goodRate = [NSString stringWithFormat:@"%d", rate];
        self.star = [self.goodRate stringByAppendingString:@"%"];
        self.addr = [dict valueForKey:@"addr"];
        self.lng = [dict valueForKey:@"lng"];
        self.storeId = [dict valueForKey:@"storeId"];
        self.lat = [dict valueForKey:@"lat"];
        return self;
        
    }
    return nil;
}

@end


@implementation CZJNearbyStoreServiceListForm
@synthesize addr = _addr;
@synthesize distance = _distance;
@synthesize evalCount = _evalCount;
@synthesize goodsCount = _goodsCount;
@synthesize homeImg = _homeImg;
@synthesize moreFlag = _moreFlag;
@synthesize name = _name;
@synthesize purchaseCount = _purchaseCount;
@synthesize star = _star;
@synthesize storeId = _storeId;

-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        self.addr = [dict valueForKey:@"addr"];
        self.distance = [dict valueForKey:@"distance"];
        self.evalCount = [NSString stringWithFormat:@"%@",[dict valueForKey:@"evalCount"]];
        self.purchaseCount = [NSString stringWithFormat:@"%@",[dict valueForKey:@"purchaseCount"]];
        self.goodsCount = [NSString stringWithFormat:@"%@",[dict valueForKey:@"goodsCount"]];
        self.name = [dict valueForKey:@"name"];
        self.homeImg = [dict valueForKey:@"homeImg"];
        int rate = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"star"]] floatValue] * 100 /5;
        self.goodRate = [NSString stringWithFormat:@"%d", rate];
        self.star = [self.goodRate stringByAppendingString:@"%"];
        self.storeId = [dict valueForKey:@"storeId"];
        self.moreFlag = [[dict valueForKey:@"moreFlag"] boolValue];
        NSArray* tempAry = [dict valueForKey:@"items"];
        for (id obj in tempAry) {
            CZJStoreServiceForm* form = [[CZJStoreServiceForm alloc]initWithDictionary:obj];
            [self.items addObject:form];
        }
        
        return self;
    }
    return nil;
}
@end


@implementation CZJStoreServiceForm
@synthesize currentPrice = _currentPrice;
@synthesize evalCount = _evalCount;
@synthesize goHouseFlag = _goHouseFlag;
@synthesize goStoreFlag = _goStoreFlag;
@synthesize goodEvalRate = _goodEvalRate;
@synthesize itemImg = _itemImg;
@synthesize itemName = _itemName;
@synthesize itemType = _itemType;
@synthesize originalPrice = _originalPrice;
@synthesize purchaseCount = _purchaseCount;
@synthesize skillFlag = _skillFlag;
@synthesize skillPrice = _skillPrice;
@synthesize storeItemPid = _storeItemPid;

-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        self.evalCount = [dict valueForKey:@"evalCount"];
        self.goHouseFlag = [dict valueForKey:@"goHouseFlag"];
        self.goStoreFlag = [dict valueForKey:@"goStoreFlag"];
        self.goodEvalRate = [dict valueForKey:@"goodEvalRate"];
        self.itemImg = [dict valueForKey:@"itemImg"];
        self.itemName = [dict valueForKey:@"itemName"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.originalPrice = [dict valueForKey:@"originalPrice"];
        self.purchaseCount = [dict valueForKey:@"purchaseCount"];
        self.skillFlag = [dict valueForKey:@"skillFlag"];
        self.skillPrice = [dict valueForKey:@"skillPrice"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"] ;
        return self;
    }
    return nil;
}


@end




