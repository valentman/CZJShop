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
        
        NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
        
        float longitude = [standard floatForKey:CCLastLongitude];
        float latitude = [standard floatForKey:CCLastLatitude];
        self.longitude = longitude;
        self.latitude = latitude;
        self.lastCoordinate = CLLocationCoordinate2DMake(longitude,latitude);
        self.lastCity = [standard objectForKey:CCLastCity];
        self.lastAddress=[standard objectForKey:CCLastAddress];
        
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
            UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"查看附近门店功能需要使用定位,请到'设置->隐私->定位服务'开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alvertView show];
            [USER_DEFAULT setObject:@"" forKey:CCLastAddress];
        }
    }

}
- (BOOL)isLocationEnable{
    BOOL isEnable = NO;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        isEnable = YES;
    }
    else
    {
        [USER_DEFAULT setObject:@"" forKey:CCLastAddress];
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
             
             _country = placemark.country;
             _province = placemark.administrativeArea;
             _city = [NSString stringWithFormat:@"%@",placemark.locality];
             if (!_city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 _city = placemark.administrativeArea;
             }
             [USER_DEFAULT setObject:_city forKey:CCLastCity];
             _subCity = [placemark.subLocality isEqualToString:@"null"] ? @"" : placemark.subLocality;
             _bigRoad = [placemark.thoroughfare isEqualToString:@"null"] ? @"" : placemark.thoroughfare;
             _street = [placemark.subThoroughfare isEqualToString:@"null"] ? @"" : placemark.subThoroughfare;
             
             //获取地级市以下详细地址
             _lastAddress = [NSString stringWithFormat:@"%@%@%@%@",_city,_subCity,_bigRoad,_street];
             [USER_DEFAULT setObject:_lastAddress forKey:CCLastAddress];
             DLog(@"#######%@",_lastAddress);
             
             //获取当前城市名称
             _justCity = _city;
             [USER_DEFAULT setObject:_justCity forKey:CCLastCity];//城市市地址

             DLog(@"city = %@", _justCity);
             if (_stringBlock) {
                _stringBlock(_justCity);
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
