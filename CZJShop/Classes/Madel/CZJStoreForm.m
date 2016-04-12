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

- (id)init
{
    if (self = [super init]) {
        _provinceForms = [NSMutableArray array];
        _cityForms = [NSMutableArray array];
        _storeListForms = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (void)setNewStoreListDataWithDictionary:(NSDictionary*)dict
{
    [_storeListForms removeAllObjects];
    [self appendStoreListData:dict];
}

- (void)appendStoreListData:(NSDictionary*)dict
{
    NSArray* storelist = [dict valueForKey:@"msg"];
    for (id obj in storelist )
    {
        CZJNearbyStoreForm* storeForm =  [CZJNearbyStoreForm objectWithKeyValues:obj];
        [_storeListForms addObject:storeForm];
    }
}

- (void)setNewProvinceDataWithDictionary:(NSDictionary*)dict
{
    [_provinceForms removeAllObjects];
    [_cityForms removeAllObjects];

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
@end


@implementation CZJStoreServiceForm
@end




