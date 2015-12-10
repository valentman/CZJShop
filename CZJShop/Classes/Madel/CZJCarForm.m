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

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init])
    {
        _haveCarsForms = [NSMutableArray array];
        _carBrandsForms = [NSMutableArray array];
        return self;
    }
    return nil;
}

-(void)setNewDictionary:(NSDictionary*)dictionary
{
    [self cleanData];
    NSArray* carbrands = [[dictionary valueForKey:@"msg"] valueForKey:@"brands"];
    for (id obj in carbrands) {
        CarBrandsForm* tmp_ser = [[CarBrandsForm alloc] initWithDictionary:obj];
        [_carBrandsForms addObject:tmp_ser];
    }
    
    NSArray* haveCars = [[dictionary valueForKey:@"msg"] valueForKey:@"cars"];
    for (id obj in haveCars) {
        HaveCarsForm* tmp_ser = [[HaveCarsForm alloc] initWithDictionary:obj];
        [_haveCarsForms addObject:tmp_ser];
    }
}

-(void)cleanData
{
    [_haveCarsForms removeAllObjects];
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
        self.brandId = [dict valueForKey:@"brandId"];
        return self;
    }
    return nil;
}
@end


@implementation HaveCarsForm
@synthesize modelId = _modelId;
@synthesize icon = _icon;
@synthesize carId = _carId;
@synthesize name = _name;
@synthesize dftFlag = _dftFlag;

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.modelId = [dict valueForKey:@"modelId"];
        self.icon = [dict valueForKey:@"icon"];
        self.carId = [dict valueForKey:@"carId"];
        self.name = [dict valueForKey:@"name"];
        self.dftFlag = [dict valueForKey:@"dftFlag"];
        return self;
    }
    return nil;
}


@end