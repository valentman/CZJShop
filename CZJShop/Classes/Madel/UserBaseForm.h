//
//  UserBaseForm.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface DeafualtCarModel : NSObject

@property(nonatomic,assign)int modelId;
@property(nonatomic,strong)NSString* icon;
@property(nonatomic,strong)NSString* carId;
@property(nonatomic,strong)NSString* name;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface UserBaseForm : NSObject

@property(nonatomic,strong)NSString* cityId;
@property(nonatomic,strong)NSString* cityName;
@property(nonatomic,strong)NSString* chezhuId;
@property(nonatomic,strong)NSString* mobile;
@property(nonatomic,strong)NSString* chezhuName;
@property(nonatomic,strong)DeafualtCarModel* defaultCar;

-(void)setCityIdAndCityName:(NSDictionary*)dictionary;
-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
