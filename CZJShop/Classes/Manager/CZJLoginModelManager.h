//
//  CZJLoginModelManager.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDAlertView.h"

@class UserBaseForm;
@class StartPageForm;

@interface CZJLoginModelManager : NSObject{
    NSString* _cheZhuId;
    UserBaseForm* _usrBaseForm;
    
}
@property(nonatomic,retain)NSString* cheZhuId;
@property(nonatomic,retain)NSString* mobile;
@property(nonatomic,retain)UserBaseForm* usrBaseForm;
@property(nonatomic,retain)NSString* cityId;
@property(nonatomic,retain)NSString* cityName;
@property(nonatomic,retain)NSString* chezhuName;
@property(nonatomic,retain)StartPageForm*  startPageForm;

singleton_interface(CZJLoginModelManager)

- (void)loginMobilephone:(NSString *)phone
                password:(NSString *)password
                 success:(CZJSuccessBlock)success
                    fail:(CZJGeneralBlock)fail;

- (void)loginWithDefaultInfoSuccess:(CZJGeneralBlock)success
                               fail:(CZJGeneralBlock)fail;

- (void)registerAccountPhone:(NSString*)phone
                    password:(NSString*)password
                     success:(CZJGeneralBlock)success
                        fail:(CZJGeneralBlock)fail;

- (void)findPasswordPhone:(NSString*)phone
         verificationCode:(NSString*)code
                 password:(NSString*)password
                  success:(CZJGeneralBlock)success
                     fail:(CZJGeneralBlock)fail;

- (void)sendRegisterCodeWithPhone:(NSString*)phone
                          success:(CZJGeneralBlock)success
                             fail:(CZJGeneralBlock)fail;

- (void)sendAuthCodeWithIphone:(NSString*)phone
                       success:(CZJGeneralBlock)success
                          fail:(CZJGeneralBlock)fail;

- (void)logOffSuccess:(CZJGeneralBlock)success
                 fail:(CZJGeneralBlock)fail;

-(void)loadStartPageSuccess:(CZJSuccessBlock)success
                       Fail:(CZJGeneralBlock)fail;
//查询自己的城市ID
- (void)getCityNameByLoctaion;
- (void)questCityIdByName:(NSString*)choiceCityName
                  success:(CZJSuccessBlock)success
                     fail:(CZJGeneralBlock)fail;

- (BOOL)saveDataToLocal:(id)json;
- (NSData*)readDataFromLocal;

@end
