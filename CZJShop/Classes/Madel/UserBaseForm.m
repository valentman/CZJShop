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

- (void)setUserInfoWithDictionary:(NSDictionary*)dict
{
    self.cityId = [dict valueForKey:@"cityId"] == nil ? self.cityId : [dict valueForKey:@"cityId"];
    self.cityName = [dict valueForKey:@"cityName"] == nil ? self.cityName : [dict valueForKey:@"cityName"];
    self.chezhuId = [dict valueForKey:@"chezhuId"] == nil ? self.chezhuId : [dict valueForKey:@"chezhuId"];
    self.kefuId = [dict valueForKey:@"kefuId"] == nil ? self.kefuId : [dict valueForKey:@"kefuId"];
    self.kefuHead = [dict valueForKey:@"kefuHead"] == nil ? self.kefuHead : [dict valueForKey:@"kefuHead"];
    
    self.name = [dict valueForKey:@"name"] == nil ? self.name : [dict valueForKey:@"name"];
    self.mobile = [dict valueForKey:@"mobile"] == nil ? self.mobile : [dict valueForKey:@"mobile"];
    self.headPic = [dict valueForKey:@"headPic"] == nil ? self.headPic : [dict valueForKey:@"headPic"];
    self.levelName = [dict valueForKey:@"levelName"] == nil ? self.levelName : [dict valueForKey:@"levelName"];
    self.isHaveNewMessage = [[dict valueForKey:@"isHaveNewMessage"]boolValue];
    self.sex = [dict valueForKey:@"sex"]  == nil ? self.sex : [dict valueForKey:@"sex"];
    
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
    self.nopay = [dict  valueForKey:@"nopay"]  == nil ? self.nopay : [dict  valueForKey:@"nopay"];
    self.nobuild = [dict  valueForKey:@"nobuild"] == nil ? self.nobuild : [dict  valueForKey:@"nobuild"];
    self.noreceive = [dict  valueForKey:@"noreceive"] == nil ? self.noreceive : [dict  valueForKey:@"noreceive"];
    self.noevaluate = [dict  valueForKey:@"noevaluate"] == nil ? self.noevaluate : [dict  valueForKey:@"noevaluate"];
    
    self.money = [dict valueForKey:@"money"] == nil ? self.money : [dict valueForKey:@"money"];
    self.redpacket = [dict valueForKey:@"redpacket"] == nil ? self.redpacket : [dict valueForKey:@"redpacket"];
    self.point = [dict valueForKey:@"point"] == nil ? self.point : [dict valueForKey:@"point"];
    self.coupon = [dict valueForKey:@"coupon"] == nil ? self.coupon : [dict valueForKey:@"coupon"];
    self.card = [dict valueForKey:@"card"] == nil ? self.card : [dict valueForKey:@"card"];
    self.hotline = [dict valueForKey:@"hotline"] == nil ? self.hotline : [dict valueForKey:@"hotline"];
    
    self.couponMoney = [dict valueForKey:@"couponMoney"] == nil ? self.couponMoney : [dict valueForKey:@"couponMoney"];
    self.couponCode = [dict valueForKey:@"couponCode"] == nil ? self.couponCode : [dict valueForKey:@"couponCode"];
    self.imId = [dict valueForKey:@"imId"] == nil ? self.imId :[dict valueForKey:@"imId"];
    self.defaultCar = [DeafualtCarModel objectWithKeyValues:[dict  valueForKey:@"car"]];
}
@end

@implementation DeafualtCarModel
@end