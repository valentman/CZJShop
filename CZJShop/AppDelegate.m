
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

- (void)updateTimerLabel
{
    
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

#pragma mark- AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //-------------------1.版本更新检测------------------
    
    
    //------------------2.设置URL缓存机制----------------
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:40 * 1024 * 1024 diskCapacity:40 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    
    //------------------3.登录设置----------------
    [CZJLoginModelInstance loginWithDefaultInfoSuccess:^
    {
        if ([USER_DEFAULT valueForKey:kCZJUserName])
        {
            [USER_DEFAULT setObject:@"" forKey:kCZJUserName];
        }
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
    
    DLog(@"--%@",[CZJLoginModelManager sharedCZJLoginModelManager].usrBaseForm.cityId);
    [XGPush setTag:[CZJLoginModelManager sharedCZJLoginModelManager].usrBaseForm.cityId];
    BOOL isLoginedIn = [USER_DEFAULT boolForKey:kCZJIsUserHaveLogined];
    if (isLoginedIn) {
        [CZJLoginModelInstance loginWithDefaultInfoSuccess:^()
         {
             [XGPush setAccount:CZJLoginModelInstance.usrBaseForm.chezhuId];
         }fail:^(){}];
    }
    
    
    //-----------------6.设置主页并判断是否启动广告页面--------------
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *_CZJRootViewController = [CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDHomeView];
    self.window.rootViewController = _CZJRootViewController;
    [self.window makeKeyAndVisible];
    
    if (![USER_DEFAULT valueForKey:kCZJIsFirstLogin])
    {
        //----------------第一次进入显示引导页-----------------
        [USER_DEFAULT setValue:@"1" forKey:kCZJIsFirstLogin];
        [self guidePages];
        
        //---------------然后下载下次启动显示的启动页------------
        [self getStartPageDataFromServer:YES];
    }
    else
    {
        //-------------否则启动之后跳转到广告页-------------
        NSString* imagepath2 = [DocumentsDirectory stringByAppendingPathComponent:@"StartPage.jpg"];
        if ( [FileManager fileExistsAtPath:imagepath2])
        {
            CZJStartPageForm* startPageForm  = [CZJStartPageForm objectWithKeyValues:[CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kUserDefaultStartPageForm]];
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
        else
        {
            [self getStartPageDataFromServer:YES];
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
    CZJGeneralBlock successBlock = ^(void){
        //成功之后的处理
        DLog(@"[XGPush]register successBlock");
    };
    
    CZJGeneralBlock errorBlock = ^(void){
        //失败之后的处理
        DLog(@"[XGPush]register errorBlock");
    };
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    DLog(@"%@",deviceTokenStr);
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
