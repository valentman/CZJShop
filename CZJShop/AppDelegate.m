
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
#import "CZJNetworkManager.h"
#import "CZJLoginModelManager.h"
#import "CZJMessageManager.h"
#import "OpenShareHeader.h"
#import <AlipaySDK/AlipaySDK.h>
#import "XGPush.h"
#import "XGSetting.h"
#import "JRSwizzle.h"
#import "KMCGeigerCounter.h"
#import "CZJOrderPaySuccessController.h"
#import "MZGuidePages.h"
#import <KSCrash/KSCrashInstallationStandard.h>

@interface AppDelegate ()
{
    __block NSString* currentStartPateURL;
}
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
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        [_lunchView removeFromSuperview];
    }];
}

- (void)getStartPageDataFromServer:(BOOL)isLoadStartPage
{
    __weak typeof(self) weakSelf = self;
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        CZJStartPageForm* startpageFormTmp  = [CZJStartPageForm objectWithKeyValues:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        //存在本地启动页URL（旧）
        NSString* startPageUrl = [USER_DEFAULT valueForKey:kUserDefaultStartPageUrl];
        //启动时从服务器读取的启动页URL（新）
        currentStartPateURL = iPhone4 ? startpageFormTmp.startPageUrl4S : startpageFormTmp.startPageUrl;
        //第一次进入或有最新启动页时去下载
        if (![startPageUrl isEqualToString:currentStartPateURL] && isLoadStartPage)
        {
            [weakSelf downLoadStartPage:currentStartPateURL];
            [USER_DEFAULT setValue:currentStartPateURL forKey:kUserDefaultStartPageUrl];
        }
        [CZJUtils writeDictionaryToDocumentsDirectory:[startpageFormTmp.keyValues mutableCopy] withPlistName:kUserDefaultStartPageForm];
    } fail:nil andServerAPI:kCZJServerAPIGetStartPage];
}

- (void)downLoadStartPage:(NSString*)currentPageUrl
{
    [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:currentPageUrl] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        DLog(@"receivedSize:%ld, expectedSize:%ld",receivedSize,expectedSize);
    }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        NSString* imagepath2 = [DocumentsDirectory stringByAppendingPathComponent:@"StartPage.jpg"];
        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
        if ([UIImageJPEGRepresentation(image,0) writeToFile:imagepath2 atomically:YES])
        {
            DLog(@"启动页图片存入本地成功");
        }
        else
        {
            DLog(@"启动页图片存入本地失败");
        }
        
    }];
}



- (void)initUserDefaultDatas
{
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeDay];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeMin];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultRandomCode];
    
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelType];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelID];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedBrandID];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPrice];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultEndPrice];
    [USER_DEFAULT setValue:@"false" forKey:kUSerDefaultStockFlag];
    [USER_DEFAULT setValue:@"false" forKey:kUSerDefaultPromotionFlag];
    [USER_DEFAULT setValue:@"false" forKey:kUSerDefaultRecommendFlag];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultServicePlace];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailStoreItemPid];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailItemCode];
    
    [USER_DEFAULT setObject:@"" forKey:kUSerDefaultSexual];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageUrl];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageImagePath];
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageForm];
    [USER_DEFAULT setObject:@"0" forKey:kUserDefaultShoppingCartCount];
    [USER_DEFAULT setObject:@"0" forKey:kCZJDefaultCityID];
    [USER_DEFAULT setObject:@"" forKey:kCZJDefaultyCityName];
}

- (void)guidePages
{
    //数据源
    NSArray *imageArray = @[ @"loading01", @"loading02", @"loading03"];
    
    //  初始化方法1
    MZGuidePages *mzgpc = [[MZGuidePages alloc] init];
    mzgpc.imageDatas = imageArray;
    __weak typeof(MZGuidePages) *weakMZ = mzgpc;
    mzgpc.buttonAction = ^{
        [UIView animateWithDuration:2.0f
                         animations:^{
                             weakMZ.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [weakMZ removeFromSuperview];
                         }];
    };
    
    //  初始化方法2
    //    MZGuidePagesController *mzgpc = [[MZGuidePagesController alloc]
    //    initWithImageDatas:imageArray
    //                                                                            completion:^{
    //                                                                              NSLog(@"click!");
    //
    
    //要在makeKeyAndVisible之后调用才有效
    [self.window addSubview:mzgpc];
}

#pragma mark- AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //-------------------1.版本更新检测------------------
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    //------------------2.设置URL缓存机制----------------
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:40 * 1024 * 1024 diskCapacity:40 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    
    //------------------3.登录设置----------------
    [CZJLoginModelInstance loginWithDefaultInfoSuccess:^
    {
        if (![USER_DEFAULT valueForKey:kCZJDefaultCityID] ||
            ![USER_DEFAULT valueForKey:kCZJDefaultyCityName])
        {
            [USER_DEFAULT setObject:kCZJChengduID forKey:kCZJDefaultCityID];
            [USER_DEFAULT setObject:kCZJChengdu forKey:kCZJDefaultyCityName];
            CZJLoginModelInstance.usrBaseForm.cityId = kCZJChengduID;
            CZJLoginModelInstance.usrBaseForm.cityName = kCZJChengdu;
        }
        else
        {
            CZJLoginModelInstance.usrBaseForm.cityId = [USER_DEFAULT valueForKey: kCZJDefaultCityID];
            CZJLoginModelInstance.usrBaseForm.cityName = [USER_DEFAULT valueForKey:kCZJDefaultyCityName];
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
    //注销之后需要再次注册前的准备
    CZJGeneralBlock successBlock = ^(void)
    {
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
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
    
    //推送反馈回调版本示例
    CZJGeneralBlock _successBlock = ^(void){
        //成功之后的处理
        DLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    CZJGeneralBlock _errorBlock = ^(void){
        //失败之后的处理
        DLog(@"[XGPush]handleLaunching's errorBlock");
    };
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [XGPush handleLaunching:launchOptions successCallback:_successBlock errorCallback:_errorBlock];
    
    //给信鸽用户设置标签
    [XGPush setTag:[CZJLoginModelManager sharedCZJLoginModelManager].usrBaseForm.cityId];
    BOOL isLoginedIn = [USER_DEFAULT boolForKey:kCZJIsUserHaveLogined];
    if (isLoginedIn) {
        [CZJLoginModelInstance loginWithDefaultInfoSuccess:^()
         {
             [XGPush setAccount:CZJLoginModelInstance.usrBaseForm.chezhuId];
         }fail:^(){}];
    }
    [XGPush clearLocalNotifications];
    
    //-----------------6.设置主页并判断是否启动广告页面--------------
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *_CZJRootViewController = [CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDHomeView];
    self.window.rootViewController = _CZJRootViewController;
    [self.window makeKeyAndVisible];
    
    if (![USER_DEFAULT valueForKey:kCZJIsFirstLogin])
    {
        //----------------第一次安装App需要初始化userdefault数据-----------------
        [USER_DEFAULT setValue:@"1" forKey:kCZJIsFirstLogin];
        [self initUserDefaultDatas];
        
        //---------------然后下载下次启动显示的启动页------------
        [self getStartPageDataFromServer:YES];
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    //当版本更新后即要启动引导页
    if (![USER_DEFAULT valueForKey:kCZJLastVersion] ||
        ![[USER_DEFAULT valueForKey:kCZJLastVersion] isEqualToString:[CZJUtils getCurrentVersion]])
    {
        [USER_DEFAULT setValue:[CZJUtils getCurrentVersion] forKey:kCZJLastVersion];
        [self guidePages];
    }
    else
    {
        //-------------否则启动之后跳转到广告页-------------
        CZJStartPageForm* startPageForm  = [CZJStartPageForm objectWithKeyValues:[CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kUserDefaultStartPageForm]];
        
        //时间比较
        NSDate *firstDate = [[NSDate alloc]init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateA = [dateFormatter dateFromString:startPageForm.startPageOverdueTime];
        NSTimeInterval timeinterA = [dateA timeIntervalSince1970];
        NSTimeInterval timeinterB = [firstDate timeIntervalSince1970];
        NSLog(@"date1 : %f, date2 : %f", timeinterA, timeinterB);
        
        //过期否
        if (timeinterA > timeinterB)
        {
            NSString* imagepath2 = [DocumentsDirectory stringByAppendingPathComponent:@"StartPage.jpg"];
            if ( [FileManager fileExistsAtPath:imagepath2])
            {
                
                _lunchView = [[NSBundle mainBundle ]loadNibNamed:@"LaunchScreen" owner:nil options:nil][0];
                [_lunchView setSize:CGSizeMake(PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT)];
                [_lunchView setPosition:CGPointPositionMiddle atAnchorPoint:CGPointMiddle];
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:PJ_SCREEN_BOUNDS];
                [imageV setImage:[[UIImage alloc] initWithContentsOfFile:imagepath2]];
                [_lunchView addSubview:imageV];
                
                UIButton* tiaoguoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [tiaoguoBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
                [tiaoguoBtn setTitle:@"跳过" forState:UIControlStateNormal];
                [tiaoguoBtn setBackgroundColor:RGB(10, 10, 10)];
                [tiaoguoBtn.titleLabel setFont:BOLDSYSTEMFONT(13)];
                tiaoguoBtn.alpha = 0.5;
                tiaoguoBtn.layer.cornerRadius = 12.5;
                [tiaoguoBtn addTarget:self action:@selector(removeLun) forControlEvents:UIControlEventTouchUpInside];
                tiaoguoBtn.frame = CGRectMake(PJ_SCREEN_WIDTH - 100, 30, 70, 25);
                [_lunchView addSubview:tiaoguoBtn];
                tiaoguoBtn.hidden = !startPageForm.startPageSkip;
                
                [self.window addSubview:_lunchView];
                [self.window bringSubviewToFront:_lunchView];
                
                
                NSTimeInterval timeinterval = [startPageForm.startPageTime intValue];
                [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(removeLun) userInfo:nil repeats:NO];
                [self getStartPageDataFromServer:NO];
            }
        }
        else
        {
            [self getStartPageDataFromServer:YES];
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }
    
    
    //---------------------7.分享设置---------------------
    [OpenShare connectQQWithAppId:kCZJOpenShareQQAppId];
    [OpenShare connectWeiboWithAppKey:kCZJOpenShareWeiboAppKey];
    [OpenShare connectWeixinWithAppId:kCZJOpenShareWeixinAppId];
    [OpenShare connectAlipay];
    
    
    //-------------------8.字典描述分类替换---------------
    [NSDictionary jr_swizzleMethod:@selector(description) withMethod:@selector(my_description) error:nil];
    
    
    //-------------------9.开启帧数显示---------------
    [KMCGeigerCounter sharedGeigerCounter].enabled = false;
    
    
    //-------------------10.崩溃收集接口---------------
    KSCrashInstallationStandard* installation = [KSCrashInstallationStandard sharedInstance];
    installation.url = [NSURL URLWithString:@"https://collector.bughd.com/kscrash?key=d84c241e5cde9210eeefa96f8a784917"];
    [installation install];
    [installation sendAllReportsWithCompletion:nil];

    return YES;
}



#pragma mark- PushNotification
//注册系统为IOS8及以后的版本推送服务
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

//注册系统为IOS8之前的版本推送服务
- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

//接收本地推送通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //notification是发送推送时传入的字典信息
    [XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
    [XGPush delLocalNotification:notification];
    
//    //当App在前台运行时，远程通知转换成本地通知到这里，显示出来
//    [[[UIAlertView alloc]initWithTitle:@"通知" message:@"这是一条通知消息" delegate:self cancelButtonTitle:@"收到，闪边去~" otherButtonTitles:nil, nil] show];
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
}


//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    
    completionHandler();
}
#endif

//注册远程通知获取deviceToken成功回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    CZJGeneralBlock successBlock = ^(void){
        //成功之后的处理
        DLog(@"[XGPush]register successBlock");
    };
    
    CZJGeneralBlock errorBlock = ^(void){
        //失败之后的处理
        DLog(@"[XGPush]register errorBlock");
    };
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    DLog(@"deviceTokenStr:%@",deviceTokenStr);
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"%@", [NSString stringWithFormat: @"[XGPush] Error: %@",error]);
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
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个alertView，只是那样稍显aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"========CZJ inactive");
        //程序处于后台
        
    }
}


#pragma mark- 应用跳转
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
    
    DLog(@"%@",url.absoluteString);
    //第二步：添加回调
    if (![url.absoluteString hasPrefix:@"CheZhiJian"]) {
        DLog(@"微信");
        return [OpenShare handleOpenURL:url];
    }
    
    return YES;
}


#pragma mark- 后台前台切换
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopTimer" object:nil];
    [self beingBackgroundUpdateTask];
    /**
     *  在这里加上你需要长久运行的代码
     */
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"beginTimer" object:nil];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //清除所有通知(包含本地通知)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
//    if (CZJBaseDataInstance.curLocation.latitude == 0 &&
//        CZJBaseDataInstance.curLocation.longitude == 0) {
//        if (IS_IOS8)
//        {
//            [[CCLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate)
//             {
//                 [CZJBaseDataInstance setCurLocation:locationCorrrdinate];
//                 DLog(@"--%f",locationCorrrdinate.latitude);
//             }];
//        }
//        else if(IS_IOS7)
//        {
//            [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate)
//             {
//                 [CZJBaseDataInstance setCurLocation:locationCorrrdinate];
//             }];
//        }
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}




@end
