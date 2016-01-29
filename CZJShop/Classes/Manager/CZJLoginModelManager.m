//
//  CZJLoginModelManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJLoginModelManager.h"
#import "CZJNetworkManager.h"
#import "CZJErrorCodeManager.h"
#import "UserBaseForm.h"
#import "ZXLocationManager.h"
#import "StartPageForm.h"
#import "CCLocationManager.h"
#import "CZJBaseDataManager.h"

@implementation CZJLoginModelManager

@synthesize usrBaseForm = _usrBaseForm;
@synthesize cheZhuId = _cheZhuId;
@synthesize cheZhuMobile = _cheZhuMobile;
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
    if (![msgKey isEqual:@"0"])
    {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowErrorInfoWithErrorCode:msgKey];
        return NO;
    }
    return YES;
}


- (void)getAuthCodeWithIphone:(NSString*)phone
                       success:(void (^)())success
                          fail:(void (^)())fail{
    NSDictionary *params = @{@"mobile" : phone};
    
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json]) {
            success(json);
            DLog(@"获取验证码成功");
        }
    };
    CZJFailureBlock failure = ^()
    {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoginSendVerifiCode
                             parameters:params
                                success:successBlock
                                   fail:failure];
}


- (void)loginWithAuthCode:(NSString*)codeNum
              mobilePhone:(NSString*)phoneNum
                  success:(CZJSuccessBlock)success
                     fali:(CZJGeneralBlock)fail
{
    NSDictionary *params = @{@"mobile" : phoneNum,
                             @"code" : codeNum};
    
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json]) {
            NSDictionary* dict = [CZJUtils DataFromJson:json] ;
            _cheZhuId = [[dict valueForKey:@"msg"] valueForKey:@"chezhuId"];
            
            [CZJBaseDataInstance refreshChezhuID:_cheZhuId];
            success(json);
        }
    };
    CZJFailureBlock failure = ^()
    {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoginInByVerifiCode
                             parameters:params
                                success:successBlock
                                   fail:failure];
}


- (void)loginWithPassword:(NSString*)pwd
              mobilePhone:(NSString*)phoneNum
                  success:(CZJGeneralBlock)success
                     fali:(CZJGeneralBlock)fail
{
    NSDictionary *params = @{@"mobile" : phoneNum,
                             @"passwd" : pwd};
    
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json]) {
            self.usrBaseForm = [[UserBaseForm alloc] init];
            [self.usrBaseForm setUserInfoWithDictionary:[CZJUtils DataFromJson:json]];
            self.usrBaseForm.cityId = self.cityId;
            self.usrBaseForm.cityName = self.cityName;
            
            _cheZhuId = self.usrBaseForm.chezhuId;
            _mobile = self.usrBaseForm.mobile;
            if ([self saveLoginInfoDataToLocal:json]) {
                [USER_DEFAULT setObject:[NSNumber numberWithBool:YES] forKey:kCZJIsUserHaveLogined];
            }
            [CZJBaseDataInstance refreshChezhuID:_cheZhuId];
            CZJBaseDataInstance.userInfoForm = self.usrBaseForm;
            success(json);
        }
    };
    CZJFailureBlock failure = ^()
    {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        
        fail();
    };
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoginInByPassword
                             parameters:params
                                success:successBlock
                                   fail:failure];
}


- (void)setPassword:(NSString*)pwd
        mobliePhone:(NSString*)phoneNum
            success:(CZJGeneralBlock)success
               fali:(CZJGeneralBlock)fail
{
    NSDictionary *params = @{@"mobile" : phoneNum,
                             @"password" : pwd};
    
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json] ;
            success(json);
            DLog(@"设置密码成功");
            _cheZhuId = [[dict valueForKey:@"msg"] valueForKey:@"chezhuId"];
            _mobile = [[dict valueForKey:@"msg"] valueForKey:@"mobile"];
            self.cityName = [[dict valueForKey:@"msg"] valueForKey:@"cityName"];
            self.cityId = [[dict valueForKey:@"msg"] valueForKey:@"cityId"];
            success(json);
        }
    };
    CZJFailureBlock failure = ^()
    {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIRegisterSetPassword
                             parameters:params
                                success:successBlock
                                   fail:failure];
}


- (void)loginWithDefaultInfoSuccess:(void (^)())success
                               fail:(void (^)())fail{
    NSData* loginData = [self readLoginInfoDataFromLocal];
    if (!loginData)
    {
        return;
    }
    NSError* error;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:loginData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"json解析失败：%@",error);
        fail();
        return;
    }
    self.usrBaseForm = [[UserBaseForm alloc] init];
    [self.usrBaseForm setUserInfoWithDictionary:dict];
    self.usrBaseForm.cityId = self.cityId;
    self.usrBaseForm.cityName = self.cityName;
    _cheZhuId = self.usrBaseForm.chezhuId;
    _mobile = self.usrBaseForm.mobile;
    CZJBaseDataInstance.userInfoForm = self.usrBaseForm;
    success();
}


- (BOOL)saveLoginInfoDataToLocal:(id)json{
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


- (NSData*)readLoginInfoDataFromLocal{
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
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json]) {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            self.cityId = [[dict valueForKey:@"msg"] valueForKey:@"cityId"];
            self.cityName = [[dict valueForKey:@"msg"] valueForKey:@"cityName"];
            DLog(@"login suc");
            success(json);
        }
    };
    CZJFailureBlock failure = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    NSDictionary *params = @{@"cityName" : choiceCityName};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/loadCityIdByName.do"
                                                      parameters:params
                                                         success:successBlock
                                                            fail:failure];
}


-(void)loadStartPageSuccess:(void (^)(id json))success
                       Fail:(void (^)())fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json]) {
            self.startPageForm = [[StartPageForm alloc] initWithDictionary:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
            DLog(@"login suc");
            success(json);
        }
    };
    NSDictionary *params = @{};
    [[CZJNetworkManager sharedCZJNetworkManager] postJSONWithUrl:@"chezhu/loadStartPage.do"
                                                      parameters:params
                                                         success:successBlock                                                          fail:nil];
}

@end
