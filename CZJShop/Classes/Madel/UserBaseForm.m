//
//  UserBaseForm.m
//  CheZhiJian
//
//  Created by chelifang on 15/7/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "UserBaseForm.h"

@implementation UserBaseForm
-(id)init{
    if (self = [super init])
    {
        return self;
    }
    return nil;
}

- (void)setUserInfoWithDictionary:(NSDictionary*)dictionary
{
    self.cityId = [[dictionary valueForKey:@"msg"] valueForKey:@"cityId"];
    self.cityName = [[dictionary valueForKey:@"msg"] valueForKey:@"cityName"];
    self.chezhuId = [[dictionary valueForKey:@"msg"] valueForKey:@"chezhuId"];
    
    self.chezhuName = [[dictionary valueForKey:@"msg"] valueForKey:@"name"];
    self.mobile = [[dictionary valueForKey:@"msg"] valueForKey:@"mobile"];
    self.chezhuHeadImg = [[dictionary valueForKey:@"msg"] valueForKey:@"headPic"];
    self.chezhuType = [[dictionary valueForKey:@"msg"] valueForKey:@"levelName"];
    self.isHaveNewMessage = [[[dictionary valueForKey:@"msg"] valueForKey:@"chezhuName"]boolValue];
    self.sex = [[dictionary valueForKey:@"msg"] valueForKey:@"sex"];
    NSString* sexual;
    if (2 == [self.sex intValue])
    {
        sexual = @"女";
    }
    else if (1 == [self.sex intValue])
    {
        sexual = @"男";
    }
    else
    {
        sexual = @"保密";
    }
    [USER_DEFAULT setObject:sexual forKey:kUSerDefaultSexual];
    self.nopay = [[dictionary valueForKey:@"msg"] valueForKey:@"nopay"];
    self.nobuild = [[dictionary valueForKey:@"msg"] valueForKey:@"nobuild"];
    self.noreceive = [[dictionary valueForKey:@"msg"] valueForKey:@"noreceive"];
    self.noEvaluate = [[dictionary valueForKey:@"msg"] valueForKey:@"noEvaluate"];
    
    self.money = [[dictionary valueForKey:@"msg"] valueForKey:@"money"];
    self.redpacket = [[dictionary valueForKey:@"msg"] valueForKey:@"redpacket"];
    self.point = [[dictionary valueForKey:@"msg"] valueForKey:@"point"];
    self.coupon = [[dictionary valueForKey:@"msg"] valueForKey:@"coupon"];
    self.card = [[dictionary valueForKey:@"msg"] valueForKey:@"card"];
    self.hotline = [[dictionary valueForKey:@"msg"] valueForKey:@"hotline"];
    
    self.couponMoney = [[dictionary valueForKey:@"msg"] valueForKey:@"couponMoney"];
    self.couponCode = [[dictionary valueForKey:@"msg"] valueForKey:@"couponCode"];
    self.imId = [[dictionary valueForKey:@"msg"] valueForKey:@"imId"];
    self.defaultCar = [[DeafualtCarModel alloc]initWithDictionary:[[dictionary valueForKey:@"msg"] valueForKey:@"car"]];
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