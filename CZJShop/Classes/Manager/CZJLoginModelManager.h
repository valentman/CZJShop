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

@interface CZJLoginModelManager : NSObject{
    UserBaseForm* _usrBaseForm;
}
@property(nonatomic,retain)UserBaseForm* usrBaseForm;

singleton_interface(CZJLoginModelManager)

//获取验证码
- (void)getAuthCodeWithIphone:(NSString*)phone
                       success:(CZJGeneralBlock)success
                          fail:(CZJGeneralBlock)fail;

//验证码登录
- (void)loginWithAuthCode:(NSString*)codeNum
              mobilePhone:(NSString*)phoneNum
                  success:(CZJSuccessBlock)success
                     fali:(CZJSuccessBlock)fail;
//密码登录
- (void)loginWithPassword:(NSString*)pwd
              mobilePhone:(NSString*)phoneNum
                  success:(CZJSuccessBlock)success
                     fali:(CZJSuccessBlock)fail;

//启动验证是否登录成功，登录成功则获取用户信息
- (void)loginWithDefaultInfoSuccess:(CZJGeneralBlock)success
                               fail:(CZJGeneralBlock)fail;

//设置密码（注册或忘记密码重置）
- (void)setPassword:(NSDictionary*)params
            success:(CZJGeneralBlock)success
               fali:(CZJGeneralBlock)fail;

//查询自己的城市ID
- (void)questCityIdByName:(NSString*)choiceCityName
                  success:(CZJSuccessBlock)success
                     fail:(CZJGeneralBlock)fail;

//登录成功，写入本地文件
- (void)loginSuccess:(id)json
             success:(CZJGeneralBlock)sucessBlock
                fail:(CZJFailureBlock)failBlock;

@end
