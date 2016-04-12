//
//  CommonData.m
//  CheZhiJian
//
//  Created by chelifang on 15/9/10.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "CommonData.h"

@implementation CommonData

-(id)init{
    if (self = [super init]) {
        [self resetData];
        return self;
    }
    return nil;
}

- (void)resetData{
    _isServiceToAddCar = NO;
    _serviceName = nil;
    _serviceType = nil;
}

+ (CommonData *)shareCommonData{
    static CommonData *sharedCommonData = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCommonData = [[self alloc] init];
    });
    return sharedCommonData;
}

@end
