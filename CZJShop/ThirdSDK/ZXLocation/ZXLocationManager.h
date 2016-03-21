//
//  ZXLocationManager.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/20.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^ZxLocationBlock)(CLLocationCoordinate2D coord);
typedef void (^ZxStringBlock)(NSString* cityName);

@interface ZXLocationManager : NSObject <CLLocationManagerDelegate>

@property(nonatomic,assign)CLLocationCoordinate2D* currentCoord;

+ (ZXLocationManager *)sharedZXLocationManager;
- (void) getLocationCoordinate:(void (^)(CLLocationCoordinate2D coord))callBack;
- (void) getCityName:(ZxStringBlock)callBack;
- (void) startLocationCoord;
- (BOOL) isLocationEnable;
@end
