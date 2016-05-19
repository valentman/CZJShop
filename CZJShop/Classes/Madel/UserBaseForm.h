//
//  UserBaseForm.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>



@class DeafualtCarModel;
@interface UserBaseForm : NSObject
@property(nonatomic,strong)NSString* cityId;
@property(nonatomic,strong)NSString* cityName;
@property(nonatomic,strong)NSString* chezhuId;
@property(nonatomic,strong)NSString* mobile;
@property(nonatomic,strong)NSString* name;
@property(strong, nonatomic)NSString* kefuHead;
@property(strong, nonatomic)NSString* kefuId;
@property(nonatomic,strong)NSString* levelName;
@property(nonatomic,strong)NSString* headPic;
@property(assign)BOOL isHaveNewMessage;
@property(nonatomic,strong)NSString* sex;

@property(nonatomic,strong)NSString* nopay;
@property(nonatomic,strong)NSString* nobuild;
@property(nonatomic,strong)NSString* noreceive;
@property(nonatomic,strong)NSString* noevaluate;

@property(nonatomic,strong)NSString* money;
@property(nonatomic,strong)NSString* redpacket;
@property(nonatomic,strong)NSString* point;
@property(nonatomic,strong)NSString* coupon;
@property(nonatomic,strong)NSString* card;

@property(nonatomic,strong)NSString* couponMoney;
@property(nonatomic,strong)NSString* couponCode;
@property(nonatomic,strong)NSString* imId;
@property(nonatomic,strong)NSString* hotline;
@property(nonatomic,strong)DeafualtCarModel* defaultCar;

- (id)init;
- (void)setUserInfoWithDictionary:(NSDictionary*)dictionary;
@end


@interface DeafualtCarModel : NSObject
@end
