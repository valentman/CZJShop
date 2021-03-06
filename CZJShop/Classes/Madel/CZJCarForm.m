//
//  CZJCarForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarForm.h"

@implementation CZJCarForm
@synthesize carBrandsForms = _carBrandsForms;
@synthesize haveCarsForms = _haveCarsForms;
@synthesize carModels = _carModels;
@synthesize carSeries = _carSeries;

-(id)init
{
    if (self = [super init])
    {
        _carBrandsForms = [NSMutableDictionary dictionary]; //汽车品牌列表信息
        _carSeries = [NSMutableDictionary dictionary];     //汽车指定品牌车系列表
        _carModels = [NSMutableArray array];                //汽车车型信息列表
        _hotBrands = [NSMutableArray array];
        _haveCarsForms = [NSArray array];
        return self;
    }
    return nil;
}

-(void)setNewCarBrandsFormDictionary:(NSDictionary*)dict
{
    NSArray* carbrands = [[dict valueForKey:@"msg"] valueForKey:@"brands"];
    for (NSDictionary* dictone in carbrands) {
        CarBrandsForm* tmp_ser = [CarBrandsForm objectWithKeyValues:dictone];
        if (tmp_ser.popular)
        {
            [_hotBrands addObject:tmp_ser];
        }
        if ( _carBrandsForms.count > 0 && [_carBrandsForms objectForKey:tmp_ser.initial] )
        {
            [[_carBrandsForms objectForKey:tmp_ser.initial] addObject:tmp_ser];
        }
        else
        {
            NSMutableArray* tmp_brands = [NSMutableArray array];
            [tmp_brands addObject:tmp_ser];
            NSString* tmp_key = tmp_ser.initial;

            [_carBrandsForms setObject:tmp_brands forKey:tmp_key];
        }
    }
    NSArray* haveCars = [[dict valueForKey:@"msg"] valueForKey:@"cars"];
    _haveCarsForms = [HaveCarsForm objectArrayWithKeyValuesArray:haveCars];

}

- (void)setNewCarSeriesWithDict:(NSDictionary*)dict AndBrandName:(NSString*)brandName
{
    [_carSeries removeAllObjects];
    //对车牌数据进行整理
    NSArray* array = [dict valueForKey:@"msg"];
    for (NSDictionary* dict in array) {
        CarSeriesForm* Obj = [[CarSeriesForm alloc] initWithDictionary:dict];
        
        if (_carSeries.count > 0 && [_carSeries objectForKey:Obj.groupName]) {
            [[_carSeries objectForKey:Obj.groupName] addObject:Obj];
        }else{
            NSMutableArray* tmp_series = [NSMutableArray array];
            [tmp_series addObject:Obj];
            if (Obj.groupName || [Obj.groupName isEqualToString:@" "]) {
                [_carSeries setValue:tmp_series forKey:Obj.groupName];
            }else{
                [_carSeries setValue:tmp_series forKey:brandName];
            }
            
        }
    }
}

- (void)setNewCarModelsWithDict:(NSDictionary*)dict
{
    [_carModels removeAllObjects];
    //对车牌数据进行整理
    NSArray* array = [dict valueForKey:@"msg"];
    for (NSDictionary* dict in array) {
        CarModelForm* form = [[CarModelForm alloc] initWithDictionary:dict];
        [_carModels addObject:form];
    }
}

-(void)cleanData
{
    [_carBrandsForms removeAllObjects];
}
@end


@implementation CarBrandsForm
@synthesize icon = _icon;
@synthesize initial = _initial;
@synthesize name = _name;
@synthesize brandId = _brandId;

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.icon = [dict valueForKey:@"icon"];
        self.initial = [dict valueForKey:@"initial"];
        self.name = [dict valueForKey:@"name"];
        self.brandId = [NSString stringWithFormat:@"%@", [dict valueForKey:@"brandId"]];
        self.popular = [[dict valueForKey:@"popular"] boolValue];
        return self;
    }
    return nil;
}
@end


@implementation HaveCarsForm
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{@"haveCarID" : @"id",};
}
@end

@implementation CarSeriesForm
@synthesize groupName;
@synthesize name;
@synthesize seriesId;

-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.groupName  = [dictionary valueForKey:@"groupName"];
        self.name  = [dictionary valueForKey:@"name"];
        self.seriesId  = [[dictionary valueForKey:@"seriesId"] intValue];
        return self;
    }
    
    return nil;
}

@end

@implementation CarModelForm
@synthesize modelId;
@synthesize name;

-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.modelId = [dictionary valueForKey:@"modelId"];
        self.name = [dictionary valueForKey:@"name"];
        return self;
    }
    return nil;
}


@end

