//
//  CommonData.h
//  CheZhiJian
//
//  Created by chelifang on 15/9/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonData : NSObject
@property(nonatomic,assign)BOOL isServiceToAddCar; //是否是来自服务列表标示
@property(nonatomic,strong)NSString* serviceType;
@property(nonatomic,strong)NSString* serviceName;

+ (CommonData *)shareCommonData;
- (void)resetData;
@end
