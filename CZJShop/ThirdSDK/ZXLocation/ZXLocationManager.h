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

#define  CCLastLongitude @"CCLastLongitude"
#define  CCLastLatitude  @"CCLastLatitude"
#define  CCLastCity      @"CCLastCity"
#define  CCLastAddress   @"CCLastAddress"

typedef void (^ZxLocationBlock)(CLLocationCoordinate2D coord);
typedef void (^ZxStringBlock)(NSString* cityName);
typedef void(^NSStringBlock)(NSString *addressString);

@interface ZXLocationManager : NSObject <CLLocationManagerDelegate>

@property(nonatomic,assign)CLLocationCoordinate2D* currentCoord;
@property (nonatomic, copy) NSStringBlock addressBlock;
@property(nonatomic,assign)float latitude;
@property(nonatomic,assign)float longitude;
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;
@property(nonatomic,strong)NSString *lastCity;
@property(nonatomic,strong)NSString *justCity;
@property (nonatomic,strong) NSString *lastAddress;


@property (nonatomic, strong) NSString* country;            //国家
@property (nonatomic, strong) NSString* province;           //省份
@property (nonatomic, strong) NSString* city;               //城市
@property (nonatomic, strong) NSString* subCity;            //县级
@property (nonatomic, strong) NSString* bigRoad;            //镇级
@property (nonatomic, strong) NSString* street;             //街道


+ (ZXLocationManager *)sharedZXLocationManager;
- (void) getLocationCoordinate:(void (^)(CLLocationCoordinate2D coord))callBack;
- (void) getCityName:(ZxStringBlock)callBack;
- (void) getAddress:(NSStringBlock)addressBlock;
- (void) startLocationCoord;
- (BOOL) isLocationEnable;
@end
