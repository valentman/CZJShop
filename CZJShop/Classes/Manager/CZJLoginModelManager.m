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
#import "CCLocationManager.h"
#import "CZJBaseDataManager.h"

@implementation CZJLoginModelManager

@synthesize usrBaseForm = _usrBaseForm;

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
            [self loginSuccess:json];
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
            [self loginSuccess:json];
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

- (void)loginSuccess:(id)json
{
    self.usrBaseForm = [[UserBaseForm alloc] init];
    [self.usrBaseForm setUserInfoWithDictionary:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
    [CZJUtils writeDictionaryToDocumentsDirectory:[self.usrBaseForm.keyValues mutableCopy] withPlistName:kCZJPlistFileUserBaseForm];
    if ([self saveLoginInfoDataToLocal:json]) {
        [USER_DEFAULT setObject:[NSNumber numberWithBool:YES] forKey:kCZJIsUserHaveLogined];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeDay];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeMin];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultRandomCode];
        
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelType];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelID];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedBrandID];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPrice];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultEndPrice];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultStockFlag];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultPromotionFlag];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultRecommendFlag];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultServicePlace];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailStoreItemPid];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailItemCode];
        
        [USER_DEFAULT setObject:@"" forKey:kUSerDefaultSexual];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageUrl];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageImagePath];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageForm];
        [USER_DEFAULT setObject:@"0" forKey:kUserDefaultShoppingCartCount];
        [USER_DEFAULT setObject:@"" forKey:kCZJDefaultCityID];
        [USER_DEFAULT setObject:@"" forKey:kCZJDefaultyCityName];
    }
    [CZJBaseDataInstance refreshChezhuID];
    CZJBaseDataInstance.userInfoForm = self.usrBaseForm;
    
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
            self.usrBaseForm.chezhuId = [[dict valueForKey:@"msg"] valueForKey:@"chezhuId"];
            self.usrBaseForm.mobile = [[dict valueForKey:@"msg"] valueForKey:@"mobile"];
            self.usrBaseForm.cityName = [[dict valueForKey:@"msg"] valueForKey:@"cityName"];
            self.usrBaseForm.cityId = [[dict valueForKey:@"msg"] valueForKey:@"cityId"];
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
    
    NSDictionary* userDict = [CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kCZJPlistFileUserBaseForm];
//    NSData* loginData = [self readLoginInfoDataFromLocal];
    if (!userDict)
    {
        return;
    }
//    NSError* error;
//    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:loginData options:NSJSONReadingMutableContainers error:&error];
//    if (error) {
//        NSLog(@"json解析失败：%@",error);
//        fail();
//        return;
//    }
    self.usrBaseForm = [[UserBaseForm alloc] init];
    [self.usrBaseForm setUserInfoWithDictionary:userDict];
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


//- (NSData*)readLoginInfoDataFromLocal{
//    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *path = [cacheDir stringByAppendingPathComponent:@"loginInfo"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isExists = [fileManager fileExistsAtPath:path];
//    if (isExists) {
//        NSData* data=[NSData dataWithContentsOfFile:path options:0 error:NULL];
//        return data;
//    }
//    return nil;
//}


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
            self.usrBaseForm.cityId = [[dict valueForKey:@"msg"] valueForKey:@"cityId"];
            self.usrBaseForm.cityName = [[dict valueForKey:@"msg"] valueForKey:@"cityName"];
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

@end
