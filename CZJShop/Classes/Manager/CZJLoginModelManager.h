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
@property(nonatomic,retain)NSString* cheZhuMobile;
@property(nonatomic,retain)NSString* mobile;
@property(nonatomic,retain)NSString* cityId;
@property(nonatomic,retain)NSString* cityName;
@property(nonatomic,retain)NSString* chezhuName;

@property(nonatomic,retain)UserBaseForm* usrBaseForm;
@property(nonatomic,retain)StartPageForm*  startPageForm;

singleton_interface(CZJLoginModelManager)

//获取验证码
- (void)getAuthCodeWithIphone:(NSString*)phone
                       success:(CZJGeneralBlock)success
                          fail:(CZJGeneralBlock)fail;

//验证码登录
- (void)loginWithAuthCode:(NSString*)codeNum
              mobilePhone:(NSString*)phoneNum
                  success:(CZJSuccessBlock)success
                     fali:(CZJGeneralBlock)fail;
//密码登录
- (void)loginWithPassword:(NSString*)pwd
              mobilePhone:(NSString*)phoneNum
                  success:(CZJGeneralBlock)success
                     fali:(CZJGeneralBlock)fail;

//登录成功
- (void)loginWithDefaultInfoSuccess:(CZJGeneralBlock)success
                               fail:(CZJGeneralBlock)fail;

//设置密码（注册或忘记密码重置）
- (void)setPassword:(NSString*)pwd
        mobliePhone:(NSString*)phoneNum
            success:(CZJGeneralBlock)success
               fali:(CZJGeneralBlock)fail;

//查询自己的城市ID
- (void)questCityIdByName:(NSString*)choiceCityName
                  success:(CZJSuccessBlock)success
                     fail:(CZJGeneralBlock)fail;

//引导页
-(void)loadStartPageSuccess:(CZJSuccessBlock)success
                       Fail:(CZJGeneralBlock)fail;

@end
