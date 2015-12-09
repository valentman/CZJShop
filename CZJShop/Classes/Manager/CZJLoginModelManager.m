//
//  CZJLoginModelManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJLoginModelManager.h"
#import "CZJNetworkManager.h"
#import "CZJUtils.h"
#import "CZJErrorCodeManager.h"
#import "UserBaseForm.h"
#import "ZXLocationManager.h"
#import "StartPageForm.h"
#import "CCLocationManager.h"

@implementation CZJLoginModelManager

@synthesize usrBaseForm = _usrBaseForm;
@synthesize cheZhuId = _cheZhuId;
@synthesize cityId;
@synthesize cityName;

singleton_implementation(CZJLoginModelManager)

-(id)init{
    if (self = [super init]) {
        return self;
    }
    
    return nil;
}

- (BOOL)showAlertView:(id)info{
    NSDictionary* dict = [CZJUtils DataFromJson:info];
    
    NSString *string = [[NSString alloc] initWithData:info encoding:NSUTF8StringEncoding];
    DLog(@"%@",string);
    
    NSString* msgKey = [[dict valueForKey:@"code"] stringValue];
    if (![msgKey isEqual:@"0"]) {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowErrorInfoWithErrorCode:msgKey];
        return NO;
    }
    return YES;
}

-(void)showNetError{
    [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
}

- (void)questCityIdByName:(NSString*)choiceCityName
                  success:(void (^)(id json))success
                     fail:(void (^)())fail{
    __block  double tmp_lat = 0;
    __block  double tmp_lng = 0;
    
    if (IS_IOS8) {
        [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
            
            tmp_lat = locationCorrrdinate.latitude;
            tmp_lng = locationCorrrdinate.longitude;
            DLog(@"%f %f",locationCorrrdinate.latitude,locationCorrrdinate.longitude);
        }];
    }else if(IS_IOS7){
        [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate){
            tmp_lat = locationCorrrdinate.latitude;
            tmp_lng = locationCorrrdinate.longitude;
            DLog(@"%f %f",locationCorrrdinate.latitude,locationCorrrdinate.longitude);}];
    }
    
    NSDictionary *params = @{@"cityName" : choiceCityName};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/loadCityIdByName.do"
                                                parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           NSDictionary* dict = [CZJUtils DataFromJson:json];
                                                           self.cityId = [[dict valueForKey:@"msg"] valueForKey:@"cityId"];
                                                           self.cityName = [[dict valueForKey:@"msg"] valueForKey:@"cityName"];
                                                           DLog(@"login suc");
                                                           success(json);
                                                       }
                                                   }
                                                      fail:^(){
                                                          [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
                                                          fail();
                                                      }];
}

- (void)loginMobilephone:(NSString *)phone
                password:(NSString *)password
                 success:(void (^)(id json))success
                    fail:(void (^)())fail {
    
    NSDictionary *params = @{@"mobile" : phone,
                             @"passwd" : password};
    
    CZJSuccessBlock sucessBlock = ^(id json)
    {
        dispatch_async(dispatch_get_main_queue(), ^()
        {
            if ([self showAlertView:json])
            {
                self.usrBaseForm = [[UserBaseForm alloc] initWithDictionary:[CZJUtils DataFromJson:json]];
                self.usrBaseForm.cityId = self.cityId;
                self.usrBaseForm.cityName = self.cityName;
                
                _cheZhuId = self.usrBaseForm.chezhuId;
                _mobile = self.usrBaseForm.mobile;
                if ([self saveDataToLocal:json])
                {
                    [USER_DEFAULT setObject:[NSNumber numberWithBool:YES] forKey:kCZJIsUserHaveLogined];
                }
            }
           success(json);
           DLog(@"login suc");
        });
        
    };
    CZJFailureBlock failBlock = ^(){
        fail();
        [self showNetError];
    };
    
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/logon.do"
                                                parameters:params
                                                   success:sucessBlock
                                                      fail:failBlock];
}

- (void)registerAccountPhone:(NSString*)phone
                    password:(NSString*)password
                     success:(void (^)())success
                        fail:(void (^)())fail{
    NSDictionary *params = @{@"mobile" : phone,
                             @"passwd" : password,
                             @"cityId" : self.cityId,
                             @"cityName" : self.cityName};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/register.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           _cheZhuId = [[[CZJUtils DataFromJson:json] valueForKey:@"msg"] valueForKey:@"chezhuId"];
                                                           _mobile = [[[CZJUtils DataFromJson:json] valueForKey:@"msg"] valueForKey:@"mobile"];
                                                           self.cityName = [[[CZJUtils DataFromJson:json] valueForKey:@"msg"] valueForKey:@"cityName"];
                                                           self.cityId = [[[CZJUtils DataFromJson:json] valueForKey:@"msg"] valueForKey:@"cityId"];
                                                           success(json);
                                                           DLog(@"login suc");
                                                       }
                                                   }
                                                      fail:^(){
                                                          [self showNetError];
                                                          fail();
                                                      }];
}


- (void)findPasswordPhone:(NSString*)phone
         verificationCode:(NSString*)code
                 password:(NSString*)password
                  success:(void (^)())success
                     fail:(void (^)())fail{
    NSDictionary *params = @{@"mobile" : phone,
                             @"authCode" : code,
                             @"passwd" : password};
    
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/resetPasswd.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           success(json);
                                                           DLog(@"login suc");
                                                       }
                                                   }
                                                      fail:^(){
                                                          [self showNetError];
                                                          fail();
                                                      }];
}

- (void)sendRegisterCodeWithPhone:(NSString*)phone
                          success:(void (^)())success
                             fail:(void (^)())fail{
    
    NSDictionary *params = @{@"mobile" : phone,
                             @"cityId" : self.cityId,
                             @"cityName" : self.cityName};
    
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/sendRegisterCode.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           success(json);
                                                           DLog(@"login suc");
                                                       }
                                                   }
                                                      fail:^(){
                                                          [self showNetError];
                                                          fail();
                                                      }];
}

- (void)sendAuthCodeWithIphone:(NSString*)phone
                       success:(void (^)())success
                          fail:(void (^)())fail{
    NSDictionary *params = @{@"mobile" : phone};
    
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/sendAuthCode.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           success(json);
                                                           DLog(@"login suc");
                                                       }
                                                   }
                                                      fail:^(){
                                                          [self showNetError];
                                                          fail();
                                                      }];
}


//[NSJSONSerialization JSONObjectWithData:jsonData
//                                options:NSJSONReadingMutableContainers
//                                  error:&err];
//if(err) {
//    NSLog(@"json解析失败：%@",err);
//    return nil;
//}
- (void)loginWithDefaultInfoSuccess:(void (^)())success
                               fail:(void (^)())fail{
    NSData* loginData = [self readDataFromLocal];
    NSError* error;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:loginData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"json解析失败：%@",error);
        return;
    }
    self.usrBaseForm = [[UserBaseForm alloc] initWithDictionary:dict];
    self.usrBaseForm.cityId = self.cityId;
    self.usrBaseForm.cityName = self.cityName;
    _cheZhuId = self.usrBaseForm.chezhuId;
    _mobile = self.usrBaseForm.mobile;
    success();
    
}

- (void)logOffSuccess:(void (^)())success
                 fail:(void (^)())fail{
    NSDictionary *params = @{@"chezhuId" : _cheZhuId,
                             @"cityId"   : self.cityId};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/logoff.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           success(json);
                                                           [USER_DEFAULT setObject:[NSNumber numberWithBool:NO] forKey:kCZJIsUserHaveLogined];
                                                           DLog(@"login suc");
                                                       }
                                                   }
                                                      fail:^(){
                                                          [self showNetError];
                                                          fail();
                                                      }];
}


-(void)loadStartPageSuccess:(void (^)(id json))success
                       Fail:(void (^)())fail{
    NSDictionary *params = @{};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/loadStartPage.do" parameters:params
                                                   success:^(id json){
                                                       if ([self showAlertView:json]) {
                                                           self.startPageForm = [[StartPageForm alloc] initWithDictionary:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
                                                           DLog(@"login suc");
                                                           success(json);
                                                       }
                                                   }
                                                      fail:^(){
                                                          //     [self showNetError];
                                                          fail();
                                                      }];
}

- (BOOL)saveDataToLocal:(id)json{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cacheDir stringByAppendingPathComponent:@"loginInfo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:path];
    if (!isExists) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSString *string = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSData *resultData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",path);
    if ([resultData writeToFile:path atomically:YES]) {
        return YES;
    }
    return NO;
}

- (NSData*)readDataFromLocal{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cacheDir stringByAppendingPathComponent:@"loginInfo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:path];
    if (isExists) {
        NSData* data=[NSData dataWithContentsOfFile:path options:0 error:NULL];
        return data;
    }
    return nil;
}

- (void)getCityNameByLoctaion{
    if (IS_IOS8) {
        [[CCLocationManager shareLocation] getCity:^(NSString* cityName1){
            DLog(@"%@",cityName1);
            [self questCityIdByName:cityName1 success:^(id json){
                if ([self showAlertView:json]) {
                    if (![USER_DEFAULT valueForKey:kCZJDefaultCityID] || ![USER_DEFAULT valueForKey:kCZJDefaultyCityName]) {
                        [USER_DEFAULT setObject:self.cityId forKey:kCZJDefaultCityID];
                        [USER_DEFAULT setObject:self.cityName forKey:kCZJDefaultyCityName];
                    }
                }
                
                
            } fail:^(){
                
            }];
        }];
    }else if(IS_IOS7){
        [[ZXLocationManager sharedZXLocationManager]  getCityName:^(NSString* cityName2){
            DLog(@"%@",cityName2);
            [self questCityIdByName:cityName success:^(id json){
                if ([self showAlertView:json]) {
                    if (![USER_DEFAULT valueForKey:kCZJDefaultCityID] || ![USER_DEFAULT valueForKey:kCZJDefaultyCityName]) {
                        [USER_DEFAULT setObject:self.cityId forKey:kCZJDefaultCityID];
                        [USER_DEFAULT setObject:self.cityName forKey:kCZJDefaultyCityName];
                    }
                }
            } fail:^(){
                
            }];
        }];
    }
}
@end
