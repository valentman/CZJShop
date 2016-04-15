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
        self.headPic = @"";
        return self;
    }
    return nil;
}

- (void)setUserInfoWithDictionary:(NSDictionary*)dictionary
{
    self.cityId = [dictionary  valueForKey:@"cityId"];
    self.cityName = [dictionary  valueForKey:@"cityName"];
    self.chezhuId = [dictionary  valueForKey:@"chezhuId"];
    
    self.chezhuName = [dictionary valueForKey:@"name"];
    self.mobile = [dictionary valueForKey:@"mobile"];
    self.headPic = [dictionary valueForKey:@"headPic"];
    self.levelName = [dictionary valueForKey:@"levelName"];
    self.isHaveNewMessage = [[dictionary valueForKey:@"isHaveNewMessage"]boolValue];
    self.sex = [dictionary valueForKey:@"sex"];
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
    self.nopay = [dictionary  valueForKey:@"nopay"];
    self.nobuild = [dictionary  valueForKey:@"nobuild"];
    self.noreceive = [dictionary  valueForKey:@"noreceive"];
    self.noEvaluate = [dictionary  valueForKey:@"noEvaluate"];
    
    self.money = [dictionary valueForKey:@"money"];
    self.redpacket = [dictionary valueForKey:@"redpacket"];
    self.point = [dictionary valueForKey:@"point"];
    self.coupon = [dictionary  valueForKey:@"coupon"];
    self.card = [dictionary  valueForKey:@"card"];
    self.hotline = [dictionary  valueForKey:@"hotline"];
    
    self.couponMoney = [dictionary  valueForKey:@"couponMoney"];
    self.couponCode = [dictionary valueForKey:@"couponCode"];
    self.imId = [dictionary valueForKey:@"imId"];
    self.defaultCar = [DeafualtCarModel objectWithKeyValues:[dictionary  valueForKey:@"car"]];
}
@end

@implementation DeafualtCarModel
@end