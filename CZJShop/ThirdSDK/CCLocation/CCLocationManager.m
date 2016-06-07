//
//  CCLocationManager.m
//  MMLocationManager
//
//  Created by WangZeKeJi on 14-12-10.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "CCLocationManager.h"
#import "WGS84TOGCJ02.h"

@interface CCLocationManager (){
    CLLocationManager *_manager;

}
@property (nonatomic, strong) LocationBlock locationBlock;
@property (nonatomic, strong) NSStringBlock cityBlock;
@property (nonatomic, strong) NSStringBlock addressBlock;
@property (nonatomic, strong) LocationErrorBlock errorBlock;
@property (atomic, assign) BOOL isNeedShowAlert;

@end

@implementation CCLocationManager


+ (CCLocationManager *)shareLocation{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
        
        float longitude = [standard floatForKey:CCLastLongitude];
        float latitude = [standard floatForKey:CCLastLatitude];
        self.longitude = longitude;
        self.latitude = latitude;
        self.lastCoordinate = CLLocationCoordinate2DMake(longitude,latitude);
        self.lastCity = [standard objectForKey:CCLastCity];
        self.lastAddress=[standard objectForKey:CCLastAddress];
        self.isNeedShowAlert = YES;
    }
    return self;
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
        [USER_DEFAULT setObject:@"" forKey:CCLastCity];
        [USER_DEFAULT setObject:@"0" forKey:CCLastLatitude];
        [USER_DEFAULT setObject:@"0" forKey:CCLastLongitude];
    }
    return isEnable;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self stopLocation];
    
}

-(void)stopLocation
{
    _manager = nil;
}

#pragma mark- 开始获取位置信息
//获取经纬度
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock
{
    self.locationBlock = [locaiontBlock copy];
    [self startLocation];
}

//获取坐标和详细地址
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}

//获取详细地址
- (void) getAddress:(NSStringBlock)addressBlock
{
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}
//获取城市，定位到市级
- (void) getCity:(NSStringBlock)cityBlock
{
    self.cityBlock = [cityBlock copy];
    [self startLocation];
}


-(void)startLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        _manager=[[CLLocationManager alloc]init];
        _manager.delegate=self;
        _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;     //定位精度，暂定为十米级别
        _manager.distanceFilter=100;                                        //位置更新最小距离，暂定为100米
        
//        [_manager requestAlwaysAuthorization];
        [_manager requestWhenInUseAuthorization];
        [_manager startUpdatingLocation];                                   //开始定位追踪
    }
    else
    {
        if(self.isNeedShowAlert)
        {
            self.isNeedShowAlert = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                ;
                // 更UI
                UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"查看附近门店功能需要使用定位,请到\"设置->隐私->定位服务\"中开启。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alvertView show];
                });
            [USER_DEFAULT setObject:@"" forKey:CCLastAddress];
        }
    }
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks,NSError *error)
     {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             DLog(@"%@,%@,%@,%@,%@,%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.subThoroughfare);
             _country = placemark.country;
             _province = placemark.administrativeArea;
             _city = [NSString stringWithFormat:@"%@",placemark.locality];
             if (!_city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 _city = placemark.administrativeArea;
             }
             _subCity = [placemark.subLocality isEqualToString:@"(null)"] ? @"" : placemark.subLocality;
             _bigRoad = [placemark.thoroughfare isEqualToString:@"(null)"] ? @"" : placemark.thoroughfare;
             _street = (placemark.subThoroughfare == nil) ? @"" : placemark.subThoroughfare;
             
             //获取地级市以下详细地址
             _lastAddress = [NSString stringWithFormat:@"%@%@%@%@",_city,_subCity,_bigRoad,_street];
             [USER_DEFAULT setObject:_lastAddress forKey:CCLastAddress];
             DLog(@"#######%@",_lastAddress);
             
             //获取当前城市名称
             _justCity = _city;
             [USER_DEFAULT setObject:_justCity forKey:CCLastCity];//城市市地址
         }
         
         if (_cityBlock) {
             _cityBlock(_justCity);
             _cityBlock = nil;
         }
         if (_addressBlock) {
             _addressBlock(_lastAddress);
             _addressBlock = nil;
         }
         
         
     }];
    
    _lastCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude ,newLocation.coordinate.longitude );
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }
    
    NSLog(@"%f--%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [USER_DEFAULT setObject:@(newLocation.coordinate.latitude) forKey:CCLastLatitude];
    [USER_DEFAULT setObject:@(newLocation.coordinate.longitude) forKey:CCLastLongitude];
    
    [manager stopUpdatingLocation];   
}




@end
