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
    _cityForms = [[CZJCitysForm objectArrayWithKeyValuesArray:[dict valueForKey:@"citys"]]mutableCopy];

    NSArray* provinces = [dict valueForKey:@"provinces"];
    for (id proObj in provinces )
    {
        CZJProvinceForm* tmp_provinces = [[CZJProvinceForm alloc]initWithDictionary:proObj];
        NSString* currentProvID = [proObj valueForKey:@"provinceId"];
        for (id cityObj in _cityForms)
        {
            NSString* cityProID = [cityObj valueForKey:@"provinceId"];
            if ([currentProvID isEqualToString:@"0"])
            {
                [tmp_provinces.containCitys addObject:cityObj];
            }
            if ([currentProvID isEqualToString: cityProID]) {
                [tmp_provinces.containCitys addObject:cityObj];
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
@synthesize evaluationAvg = _evaluationAvg;
@synthesize setupCount = _setupCount;
@synthesize setupPrice = _setupPrice;
@synthesize type = _type;

-(id)initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        self.distance = [dict valueForKey:@"distance"];
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
        self.evaluationAvg = [dict valueForKey:@"evaluationAvg"];
        self.setupCount = [dict valueForKey:@"setupCount"];
        self.setupPrice = [dict valueForKey:@"setupPrice"];
        self.type = [dict valueForKey:@"type"];
        return self;
        
    }
    return nil;
}

@end



@implementation CZJStoreServiceForm

@end




