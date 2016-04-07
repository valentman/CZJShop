//
//  ZXLocationManager.m
//  CheZhiJian
//
//  Created by chelifang on 15/7/20.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "ZXLocationManager.h"

@interface ZXLocationManager ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) ZxLocationBlock locationBlock;
@property (nonatomic, strong) ZxStringBlock stringBlock;
@property (nonatomic, assign) BOOL isNeedShowAlert;
@end

@implementation ZXLocationManager

+ (ZXLocationManager *)sharedZXLocationManager{
    static ZXLocationManager *sharedZXLocationManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedZXLocationManager = [[self alloc] init];
    });
    return sharedZXLocationManager;
};

-(id)init{
    if (self = [super init]) {
         self.locationManager = [[CLLocationManager alloc] init];
         self.locationManager.delegate = self;
        self.isNeedShowAlert = YES;
        return self;
    }
    return nil;
}

- (void) startLocationCoord{
    
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {

        [self.locationManager startUpdatingLocation];
    }
    else
    {
        if (self.isNeedShowAlert) {
            self.isNeedShowAlert = NO;
            UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alvertView show];
            
        }
    }

}
- (BOOL)isLocationEnable{
    BOOL isEnable = NO;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        isEnable = YES;
    }
    return isEnable;
}

- (void) getLocationCoordinate:(void (^)(CLLocationCoordinate2D coord))callBack{
    
    self.locationBlock = [callBack copy];
    [self startLocationCoord];
}

- (void) getCityName:(void(^)(NSString* cityName))callBack{
    self.stringBlock = callBack;
    [self startLocationCoord];

}

//获取详细地址
- (void) getAddress:(NSStringBlock)addressBlock
{
    self.addressBlock = [addressBlock copy];
    [self startLocationCoord];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D tmpLocation = CLLocationCoordinate2DMake(newLocation.coordinate.latitude ,newLocation.coordinate.longitude);
    if (_locationBlock) {
        _locationBlock(tmpLocation);
        _locationBlock = nil;
    }

    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             
             _lastAddress = [NSString stringWithFormat:@"%@%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.subThoroughfare];//详细地址
             DLog(@"#######%@",_lastAddress);

             DLog(@"city = %@", city);
             if (_stringBlock) {
                _stringBlock(city);
                _stringBlock = nil;
             }
             if (_addressBlock)
             {
                 _addressBlock(_lastAddress);
                 _addressBlock = nil;
             }
             
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}
@end
