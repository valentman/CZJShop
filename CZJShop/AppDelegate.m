
//
//  AppDelegate.m
//  CZJShop
//
//  Created by Joe.Pen on 11/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "AppDelegate.h"
#import "CZJUtils.h"
#import "CCLocationManager.h"
#import "ZXLocationManager.h"
#import "CZJBaseDataManager.h"
#import "CZJLoginModelManager.h"
#import "CZJMessageManager.h"
#import "OpenShareHeader.h"
#import <AlipaySDK/AlipaySDK.h>
#import "XGPush.h"
#import "XGSetting.h"
#import "JRSwizzle.h"
#import "KMCGeigerCounter.h"
#import "CZJOrderPaySuccessController.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIView *lunchView;
@end

@implementation AppDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kCZJAPPURL]];
        sleep(2.0f);
    }
}

-(void)removeLun
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_lunchView setPosition:CGPointPositionMiddle atAnchorPoint:CGPointMiddle];
        [_lunchView setAlpha:0];
    } completion:^(BOOL finished) {
        [_lunchView removeFromSuperview];
    }];
    
}

#pragma mark- AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //-------------------1.版本更新检测------------------
    NSMutableDictionary* versionCheck_info = [CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kCZJPlistFileCheckVersion];
    if (versionCheck_info && versionCheck_info.count > 0)
    {
        NSDictionary* version_dict = [versionCheck_info valueForKey:kCZJCheckVersion];
        int enforce = [[version_dict valueForKey:kCZJEnfore] intValue];
        NSString* net_version = [version_dict valueForKey:kCZJNetVersion];
        NSString* cur_version = [[[NSBundle mainBundle] infoDictionary] valueForKey:kCZJCurVerson];
        
        if ([net_version floatValue] > [cur_version floatValue] && 1 == enforce)
        {
            [CZJUtils showExitAlertViewWithContentOnParent:self];
        }
    }
    
    
    //------------------2.设置URL缓存机制----------------
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:40 * 1024 * 1024 diskCapacity:40 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    
    //------------------3.登录设置----------------
    [CZJLoginModelInstance loginWithDefaultInfoSuccess:^
    {
        [CZJBaseDataInstance loadShoppingCartCount:nil Success:nil fail:nil];
        if ([USER_DEFAULT valueForKey:kCZJUserName])
        {
            [USER_DEFAULT setObject:@"" forKey:kCZJUserName];
        }
        if (![USER_DEFAULT valueForKey:kCZJDefaultCityID] ||
            ![USER_DEFAULT valueForKey:kCZJDefaultyCityName])
        {
            [USER_DEFAULT setObject:kCZJChengduID forKey:kCZJDefaultCityID];
            [USER_DEFAULT setObject:kCZJChengdu forKey:kCZJDefaultyCityName];
            CZJLoginModelInstance.cityId = kCZJChengduID;
            CZJLoginModelInstance.cityName = kCZJChengdu;
        }
        else
        {
            CZJLoginModelInstance.cityId = [USER_DEFAULT valueForKey: kCZJDefaultCityID];
            CZJLoginModelInstance.cityName = [USER_DEFAULT valueForKey:kCZJDefaultyCityName];
        }
    } fail:^{
        
    }];
    
    
    //--------------------4.初始化定位-------------------
    if (IS_IOS8)
    {
        [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
            [CZJBaseDataInstance setCurLocation:locationCorrrdinate];
        }];
        [[CCLocationManager shareLocation]getCity:^(NSString *addressString) {
            [CZJBaseDataInstance setCurCityName:addressString];
        }];
    }
    else if (IS_IOS7)
    {
        [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:^(CLLocationCoordinate2D coord) {
            [CZJBaseDataInstance setCurLocation:coord];
        }];
        [[ZXLocationManager sharedZXLocationManager]getCityName:^(NSString *addressString) {
            [CZJBaseDataInstance setCurCityName:addressString];
        }];
    }


    
    //--------------------5.推送注册中心-----------------
    [XGPush startApp:kCZJPushServerAppId appKey:kCZJPushServerAppKey];
    CZJGeneralBlock successBlock = ^(void)
    {
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8推送类型注册
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
        #else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
        #endif
        }
    };
    [XGPush initForReregister:successBlock];
    
    //推送反馈(app不在前台运行时，点击推送激活时)
    [XGPush handleLaunching:launchOptions];
    
    //推送反馈回调版本示例
    CZJGeneralBlock _successBlock = ^(void){
        //成功之后的处理
        DLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    CZJGeneralBlock _errorBlock = ^(void){
        //失败之后的处理
        DLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:_successBlock errorCallback:_errorBlock];
    
    DLog(@"--%@",[CZJLoginModelManager sharedCZJLoginModelManager].cityId);
    [XGPush setTag:[CZJLoginModelManager sharedCZJLoginModelManager].cityId];
    BOOL isLoginedIn = [USER_DEFAULT boolForKey:kCZJIsUserHaveLogined];
    if (isLoginedIn) {
        [CZJLoginModelInstance loginWithDefaultInfoSuccess:^()
         {
             [XGPush setAccount:[CZJLoginModelInstance cheZhuId]];
         }fail:^(){}];
    }
    
    
    //-----------------6.判断是否启动广告页面--------------
    NSString* storyboardId = @"";
    NSMutableDictionary* tmp = [CZJUtils readStartInfoPlistWithPlistName];
    if (nil != tmp)
    {
        if ([[[tmp valueForKey:@"startPage"] valueForKey:@"startPageTime"] intValue] == 0)
        {
            storyboardId = kCZJStoryBoardIDHomeView;
        }
        else
        {
            storyboardId = kCZJStoryBoardIDStartPage;
        }
    }
    else
    {
        storyboardId = kCZJStoryBoardIDHomeView;
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *_CZJRootViewController = [CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDHomeView];
    self.window.rootViewController = _CZJRootViewController;
    [self.window makeKeyAndVisible];

    //-------------------启动之后跳转到主页面中间转换页面-------------------
    _lunchView = [[NSBundle mainBundle ]loadNibNamed:@"LaunchScreen" owner:nil options:nil][0];
    [_lunchView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT)];
    [_lunchView setPosition:CGPointPositionMiddle atAnchorPoint:CGPointMiddle];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:PJ_SCREEN_BOUNDS];
    NSString *str = @"http://upload.chezhijian.com/@/yunying/201603/0b2cf7a75d6b41cba821ec2a7035e0b6.png";
    [imageV sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:DefaultPlaceHolderImage];
    [_lunchView addSubview:imageV];
    [self.window addSubview:_lunchView];
    [self.window bringSubviewToFront:_lunchView];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeLun) userInfo:nil repeats:NO];
    
    
    //---------------------7.分享设置---------------------
    [OpenShare connectQQWithAppId:kCZJOpenShareQQAppId];
    [OpenShare connectWeiboWithAppKey:kCZJOpenShareWeiboAppKey];
    [OpenShare connectWeixinWithAppId:kCZJOpenShareWeixinAppId];
    [OpenShare connectAlipay];
    
    
    //-------------------8.字典描述分类替换---------------
    [NSDictionary jr_swizzleMethod:@selector(description) withMethod:@selector(my_description) error:nil];
    
    
    //-------------------9.开启帧数显示---------------
    [KMCGeigerCounter sharedGeigerCounter].enabled = YES;

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopTimer" object:nil];
    [self beingBackgroundUpdateTask];
    // 在这里加上你需要长久运行的代码
    [self endBackgroundUpdateTask];
}


- (void)beingBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"beginTimer" object:nil];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //清除所有通知(包含本地通知)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (CZJBaseDataInstance.curLocation.latitude == 0 &&
        CZJBaseDataInstance.curLocation.longitude == 0) {
        if (IS_IOS8)
        {
            [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate)
            {
                [CZJBaseDataInstance setCurLocation:locationCorrrdinate];
                DLog(@"--%f",locationCorrrdinate.latitude);
            }];
        }
        else if(IS_IOS7)
        {
            [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate)
            {
                [CZJBaseDataInstance setCurLocation:locationCorrrdinate];
            }];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark- PushNotification
//注册IOS8及以后的推送类型
- (void)registerPushForIOS8{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    #endif
}

//注册IOS8之前的推送类型
- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

//注册获取Token成功回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    CZJGeneralBlock successBlock = ^(void){
//        //成功之后的处理
//        DLog(@"[XGPush]register successBlock");
//    };
//    
//    CZJGeneralBlock errorBlock = ^(void){
//        //失败之后的处理
//        DLog(@"[XGPush]register errorBlock");
//    };
//    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
//    DLog(@"%@",deviceTokenStr);
}

//注册获取Token失败回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"%@", [NSString stringWithFormat: @"Error: %@",error]);
}

//接收本地推送通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

//接收APNs推送通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"========CZJ receivedRemoteNotification:%@", [userInfo description]);
    [XGPush handleReceiveNotification:userInfo];
    
    [[CZJMessageManager sharedCZJMessageManager] addMessageWithObject:userInfo];
}

//接收APNs推送通知并启动或恢复应用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"========CZJ active");
        //程序当前正处于前台
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"========CZJ inactive");
        //程序处于后台
        
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        DLog(@"result ---- = %@",resultDic);
        if ([[resultDic valueForKey:@"resultStatus"] intValue] == 9000) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCZJAlipaySuccseful object:resultDic];
        }
    }];
    
    //第二步：添加回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }
    
    return YES;
}

@end
