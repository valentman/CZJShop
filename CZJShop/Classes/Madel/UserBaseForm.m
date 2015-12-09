//
//  UserBaseForm.m
//  CheZhiJian
//
//  Created by chelifang on 15/7/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "UserBaseForm.h"

@implementation UserBaseForm
@synthesize cityId;
@synthesize cityName;
@synthesize chezhuId;
@synthesize defaultCar;
@synthesize mobile;
@synthesize chezhuName;
-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.cityId = [[dictionary valueForKey:@"msg"] valueForKey:@"cityId"];
        self.cityName = [[dictionary valueForKey:@"msg"] valueForKey:@"cityName"];
        self.chezhuId = [[dictionary valueForKey:@"msg"] valueForKey:@"chezhuId"];
        self.mobile = [[dictionary valueForKey:@"msg"] valueForKey:@"mobile"];
        self.chezhuName = [[dictionary valueForKey:@"msg"] valueForKey:@"chezhuName"];
        self.defaultCar = [[DeafualtCarModel alloc]initWithDictionary:[[dictionary valueForKey:@"msg"] valueForKey:@"car"]];
        return self;
    }
    return nil;
}

-(void)setCityIdAndCityName:(NSDictionary*)dictionary{
    self.cityId = [[dictionary valueForKey:@"msg"] valueForKey:@"cityId"];
    self.cityName = [[dictionary valueForKey:@"msg"] valueForKey:@"cityName"];
}
@end

@implementation DeafualtCarModel

@synthesize modelId;
@synthesize icon;
@synthesize carId;
@synthesize name;

-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.modelId = [[dictionary valueForKey:@"modelId"] intValue];
        self.icon = [dictionary valueForKey:@"icon"];
        self.carId = [dictionary valueForKey:@"carId"];
        self.name = [dictionary valueForKey:@"name"];
        return self;
    }
    return nil;
}

@end