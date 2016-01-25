//
//  CZJUtils.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#include <objc/runtime.h>
#import "CZJUtils.h"
#import "MBProgressHUD.h"
#import "FDAlertView.h"
#import "CZJLoginController.h"
#import "CZJShoppingCartController.h"
#import "CZJNaviagtionBarView.h"
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"
#import "CZJSearchController.h"

@interface CZJUtils ()<UIAlertViewDelegate>

@end

@implementation CZJUtils
#pragma mark Zhouxin
#pragma mark- 数据解析
+ (NSDictionary*)DataFromJson:(id)json {
    
    NSDictionary *DataDic = [NSJSONSerialization JSONObjectWithData:json
                                                            options:NSJSONReadingMutableLeaves
                                                              error:nil];
    return DataDic;
}

+ (NSString*)JsonFromData:(id)data
{
    NSString *jsonString = nil;
    NSData *jsonData = [CZJUtils JsonFormData:data];
    if (!jsonData) {
        NSLog(@"Got an error");
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"jsonString:%@",jsonString);
    }
    return jsonString;
}

+(NSData*)JsonFormData:(id)data{
    
    NSError* error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    return jsonData;
}




#pragma mark /*数据持久化
#pragma mark NSData数据的持久化
+ (BOOL)saveNSDataToLocal:(NSData*)data{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cacheDir stringByAppendingPathComponent:@"history"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:path];
    if (!isExists) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSLog(@"%@",path);
    if ([data writeToFile:path atomically:YES]) {
        return YES;
    }
    return NO;
}

+ (BOOL)saveDataToLocal:(NSString*)str{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cacheDir stringByAppendingPathComponent:@"history"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:path];
    if (!isExists) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSData *resultData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",path);
    if ([resultData writeToFile:path atomically:YES]) {
        return YES;
    }
    return NO;
}

+ (NSData*)readDataFromLocal{
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cacheDir stringByAppendingPathComponent:@"history"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:path];
    if (isExists) {
        NSData* data=[NSData dataWithContentsOfFile:path options:0 error:NULL];
        return data;
    }
    return nil;
}


#pragma mark NSMutableArray数据的持久化
+ (BOOL)writeArrayToPlist:(NSMutableArray*)array withPlistName:(NSString*)plistName{
    NSString *plistPath = [PJDocumentsPath stringByAppendingPathComponent:plistName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:plistPath];
    if (!isExists) {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    return [array writeToFile:plistPath atomically:YES];
}

+ (NSMutableArray*)readArrayFromPlistWithName:(NSString*)plistName{
    NSString *plistPath = [PJDocumentsPath stringByAppendingPathComponent:plistName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:plistPath];
    if (isExists) {
        NSMutableArray* array = [NSMutableArray arrayWithContentsOfFile:plistPath];
        return array;
    }
    return nil;
}


#pragma mark 把可变字典数据的持久化
+ (BOOL)writeDataToPlist:(NSMutableDictionary*)dict withPlistName:(NSString*)plistName
{
    NSError *error;
    NSString *plistPath = [PJDocumentsPath stringByAppendingPathComponent:plistName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:plistPath];
    if (!isExists) {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:dict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                  options:NSPropertyListMutableContainersAndLeaves
                                                                    error:&error];
    if(plistData) {
        return [plistData writeToFile:plistPath atomically:YES];
    }
    return NO;
}

+ (NSMutableDictionary*)readDataFromPlistWithName:(NSString*)plistName
{
    NSError *error;
    NSPropertyListFormat format;
    NSString *plistPath = [PJDocumentsPath stringByAppendingPathComponent:plistName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:plistPath];
    if (isExists) {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSMutableDictionary* dic =[NSPropertyListSerialization propertyListWithData:plistXML
                                                                            options:NSPropertyListMutableContainersAndLeaves
                                                                             format:&format
                                                                              error:&error];
        return dic;
    }
    return nil;
}


#pragma mark 启动页面数据的读取
+ (NSMutableDictionary*)readStartInfoPlistWithPlistName
{
    return [self readDataFromPlistWithName:kCZJPlistFileStartInfo];
}

+ (void)writeStarInfoDataToPlist:(NSDictionary*)dict{
    [self writeDataToPlist:[dict mutableCopy] withPlistName:kCZJPlistFileStartInfo];
}
#pragma mark*/


#pragma mark 正则判断
+ (BOOL)isLicencePlate:(NSString *)plateNum{
    NSString* PhoneNum = @"^[A-Z0-9]\\d{5}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PhoneNum];
    if ([regextestmobile evaluateWithObject:plateNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isPhoneNumber:(NSString *)mobileNum{
    NSString* PhoneNum = @"^\\d{11}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PhoneNum];
    if ([regextestmobile evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    
    if (!mobileNum) {
        return NO;
    }
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\\\d{3})\\\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark UI组件设置
+( UIColor *) getColorFromString:( NSString *)hexColor
{
    unsigned int red, green, blue;
    NSRange range;
    range. length = 2 ;
    range. location = 0 ;
    [[ NSScanner scannerWithString :[hexColor substringWithRange :range]] scanHexInt :&red];
    range. location = 2 ;
    [[ NSScanner scannerWithString :[hexColor substringWithRange :range]] scanHexInt :&green];
    range. location = 4 ;
    [[ NSScanner scannerWithString :[hexColor substringWithRange :range]] scanHexInt :&blue];
    return [ UIColor colorWithRed :( float )(red/ 255.0f ) green :( float )(green/ 255.0f ) blue :( float )(blue/ 255.0f ) alpha : 1.0f ];
}

+ (void)setSepratorColorforTableView:(UITableView *)tableView{
    tableView.separatorColor = RGBA(230.0f, 230.0f, 230.0f, 1.0f);
}

+ (void)setExtraCellLineHidden: (UITableView *)tableView{
    tableView.separatorColor = RGBA(230.0f, 230.0f, 230.0f, 1.0f);
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
    
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}



+ (void)hideSearchBarViewForTarget:(UIViewController*)target
{
    UINavigationBar* bar =  target.navigationController.navigationBar;
    [bar setBackgroundColor:RGBA(240, 16, 35, 0.0)];
    NSArray* _barSubViews = [bar subviews];
    for (id object in _barSubViews) {
        if ([object tag] == CZJNaviBarViewTypeHome)
        {
            [object setHidden:YES];
        }
    }
}

void backLastView(id sender, SEL _cmd)
{
    [((UIViewController*)sender).navigationController popViewControllerAnimated:YES];
}

+ (void)customizeNavigationBarForTarget:(UIViewController*)target
{
    SEL backToLastView = sel_registerName("backLastView:");
    class_addMethod([target class],backToLastView,(IMP)backLastView,"v@:");    //动态的给类添加一个方法
    
    //UIButton
    UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(- 20 , 0 , 44 , 44 )];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_backnor"] forState:UIControlStateNormal];
    [leftBtn addTarget:target action:backToLastView forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
    
    //UIBarButtonItem
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -20 ;//这个数值可以根据情况自由变化
        target.navigationItem.leftBarButtonItems = @[negativeSpacer, leftItem];
        
    } else
    {
        target.navigationItem.leftBarButtonItem = leftItem;
    }
    target.navigationController.interactivePopGestureRecognizer.delegate = (id)target;
    
}


+ (void)fullScreenGestureRecognizeForTarget:(UIViewController*)currenTarget
{
    UIGestureRecognizer* gesture = currenTarget.navigationController.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    UIView* gestureView = gesture.view;
    
    NSMutableArray* _targets = [gesture valueForKey:@"_targets"];
    id gestureRecogizerTarget = [_targets firstObject];
    id navigationInteractiveTransition = [gestureRecogizerTarget valueForKey:@"_target"];
    SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:navigationInteractiveTransition action:handleTransition];
    [gestureView addGestureRecognizer:pan];
}


#pragma mark Frames
+ (float)xSizeScale{
    
    return PJ_SCREEN_WIDTH/320;
    
}

+ (float)ySizeScale{
    return PJ_SCREEN_HEIGHT / 568;
}

+ (CGRect)TCGRectMake:(CGRect)crt{
    CGRect rect;
    rect.origin.x = crt.origin.x * [CZJUtils xSizeScale];
    rect.origin.y = crt.origin.y * [CZJUtils ySizeScale];
    rect.size.width = crt.size.width * [CZJUtils xSizeScale];
    rect.size.height= crt.size.height* [CZJUtils ySizeScale];
    return rect;
}


#pragma mark 提示框
+(void)tipWithText:(NSString *)text andView:(UIView *)view
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0)
    {
        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
        for(UIView *aSubView in subView.subviews)
        {
            [aSubView.layer removeAllAnimations];
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:subView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
        hud.margin = 15.f;
        hud.yOffset = 20.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud setYOffset:PJ_SCREEN_HEIGHT/4];
        [hud hide:YES afterDelay:3];
    }
}

+ (UIView*)showInfoCanvasOnTarget:(id)target action:(SEL)buttonSel{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, (PJ_SCREEN_HEIGHT-100)/2, PJ_SCREEN_WIDTH, 200)];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_icon_noweb.png"]];
    image.frame = CGRectMake((PJ_SCREEN_WIDTH - 60)/2,0, 60, 60);
    [view addSubview:image];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, PJ_SCREEN_WIDTH, 24)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont boldSystemFontOfSize:14];
    lab.textColor = RGBA(51, 51, 51, 1);
    lab.text = @"网络异常，请确认当前网络是否连接";
    [view addSubview:lab];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - 60)/2, 104, 60, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button setTitleColor:RGBA(255, 0, 0, 255) forState:UIControlStateNormal];
    [button addTarget:target action:buttonSel forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}


+ (void)showExitAlertViewWithContent{
    
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:kCZJTitle
                                                     message:kCZJMessageUpdate
                                                    delegate:self
                                           cancelButtonTitle:kCZJCancelTitle otherButtonTitles:kCZJConfirmUpdateTitle, nil];
    [alert show];
}

+ (void)showExitAlertViewWithContentOnParent:(id)parent
{
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:kCZJTitle
                                                     message:kCZJMessageUpdate
                                                    delegate:parent
                                           cancelButtonTitle:kCZJCancelTitle otherButtonTitles:kCZJConfirmUpdateTitle, nil];
    [alert show];
}



#pragma mark- PJoe
#pragma mark 字符串处理
+ (NSString*)getExplicitServerAPIURLPathWithSuffix:(NSString*)urlStr{
    return [NSString stringWithFormat:@"%@%@",kCZJServerAddr,urlStr];
}

+ (CGSize)calculateTitleSizeWithString:(NSString *)string AndFontSize:(CGFloat)fontSize
{
    return [self calculateStringSizeWithString:string Font:SYSTEMFONT(fontSize) Width:280];
}

+ (CGSize)calculateTitleSizeWithString:(NSString *)string WithFont:(UIFont*)font
{
    return [self calculateStringSizeWithString:string Font:font Width:280];
}

+ (CGSize)calculateStringSizeWithString:(NSString*)string Font:(UIFont*)font Width:(CGFloat)width
{
    NSDictionary *dic = @{NSFontAttributeName: font};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

+ (NSMutableAttributedString*)stringWithDeleteLine:(NSString*)string
{
    NSUInteger length = [string length];
    if (0 == length) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:string];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(1, length-1)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:UIColorFromRGB(0x999999) range:NSMakeRange(1, length-1)];
    return attri;
}


#pragma mark 界面控制器处理
+ (UIViewController*)getViewControllerFromStoryboard:(NSString*)storyboardName andVCName:(NSString*)vcName
{
    //获取storyboard: 通过bundle根据storyboard的名字来获取我们的storyboard,
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    return [story instantiateViewControllerWithIdentifier:vcName];
}

+ (id)getXibViewByName:(NSString*)xibName
{
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:xibName owner:self options:nil];
    return [nib objectAtIndex:0];
}

+ (void)showSearchView:(CZJViewController*)target andNaviBar:(CZJNaviagtionBarView*)naviBar
{
    UINavigationController* searchVC = (UINavigationController*)[self getViewControllerFromStoryboard:@"Main" andVCName:@"searchVCSBID"];
    
    //把searchVC加入到当前navigationController中
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    window.rootViewController = searchVC;
    target.window = window;
    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        target.window.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
//        ((CZJSearchController*)searchVC.topViewController).delegate = naviBar ? naviBar : target;
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}

+ (void)showLoginView:(CZJViewController*)target andNaviBar:(CZJNaviagtionBarView*)naviBar
{
    //由storyboard根据LoginView获取到登录界面
    UINavigationController* loginView = (UINavigationController*)[self getViewControllerFromStoryboard:@"Main" andVCName:@"LoginView"];
    
    //把loginView加入到当前navigationController中
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    window.rootViewController = loginView;
    target.window = window;
    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        target.window.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
        ((CZJLoginController*)loginView.topViewController).delegate = naviBar ? naviBar : target;
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}

+ (void)showShoppingCartView:(CZJViewController*)target  andNaviBar:(CZJNaviagtionBarView*)naviBar
{
    //由storyboard根据LoginView获取到登录界面
    UINavigationController *shopping = (UINavigationController*)[self getViewControllerFromStoryboard:@"Main" andVCName:@"ShoppingCart"];
    
    //把loginView加入到当前navigationController中
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT)];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    window.rootViewController = shopping;
    target.window = window;
    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        target.window.frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
        ((CZJShoppingCartController*)shopping.topViewController).delegate = naviBar ? naviBar : target;
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }];
}



+ (void)removeLoginViewFromCurrent:(CZJViewController*)target
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        target.window.frame = CGRectMake(0, PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
        
    }
    completion:^(BOOL finished)
    {
        if (finished) {
            [target.window resignKeyWindow];
            target.window  = nil;
        }
    }];
}

+ (void)removeShoppintCartViewFromCurrent:(CZJViewController*)target
{
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        target.window.frame = CGRectMake(PJ_SCREEN_WIDTH, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT);
    }
    completion:^(BOOL finished)
    {
        if (finished) {
            [target.window resignKeyWindow];
            target.window  = nil;
        }
    }];
}


#pragma mark 其它方法
+ (BOOL)isTimeCrossOneDay
{//判断俩次启动相隔时长
    
    UInt64 currentTime = [[NSDate date] timeIntervalSince1970];     //当前时间
    UInt64 lastUpdateTime = [[USER_DEFAULT valueForKey:kUserDefaultTimeDay] longLongValue];   //上次更新时间
    UInt64 intervalTime = currentTime - lastUpdateTime;
    if (0 == lastUpdateTime ||
        intervalTime > 86400)
    {
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%llu",currentTime] forKey:kUserDefaultTimeDay];
        return YES;
    }
    return NO;
}


+ (BOOL)isTimeCrossFiveMin:(int)intervalMin
{
    UInt64 currentTime = [[NSDate date] timeIntervalSince1970];     //当前时间
    UInt64 lastUpdateTime = [[USER_DEFAULT valueForKey:kUserDefaultTimeMin] longLongValue];   //上次更新时间
    UInt64 intervalTime = currentTime - lastUpdateTime;
    if (0 == lastUpdateTime ||
        intervalTime > intervalMin*60)
    {
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%llu",currentTime] forKey:kUserDefaultTimeMin];
        return YES;
    }
    return NO;
}

+ (void)printClassMethodList:(id)target
{
    Class currentClass=[target class];
    while (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        unsigned int i = 0;
        for (; i < methodCount; i++) {
            NSLog(@"%@ - %@", [NSString stringWithCString:class_getName(currentClass) encoding:NSUTF8StringEncoding], [NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding]);
        }
        
        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }
}

+ (void)printClassMemberVarible:(id)target
{
    unsigned int count = 0;
    Ivar* var = class_copyIvarList([target class], &count);
    for (int i = 0; i < count; i++)
    {
        Ivar _var = *(var + i);
        DLog(@"%s, %s",ivar_getTypeEncoding(_var), ivar_getName(_var));
    }
}

+ (void)performBlock:(CZJGeneralBlock)block afterDelay:(NSTimeInterval)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

+ (void)callHotLine:(NSString*)phoneNum AndTarget:(id)target
{
    /*  第一种调用拨打电话的方式
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneNum];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [target addSubview:callWebview];
     */
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

+ (CATextLayer *)creatTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point andNumOfMenu:(int)_numOfMenu
{
    
    CGSize size = [self calculateTitleSizeWithString:string AndFontSize:15];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (PJ_SCREEN_WIDTH / _numOfMenu) - 25) ? size.width : PJ_SCREEN_WIDTH / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = 15.0;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}


+ (void)showGoodsServiceDetailView:(UINavigationController*)navi
                        andItemPid:(NSString*)sid
                        detailType:(CZJDetailType)detailtype
{
    CZJDetailViewController* detailView = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"goodsDetailSBID"];
    detailView.storeItemPid = sid;
    detailView.detaiViewType = detailtype;
    [navi pushViewController:detailView animated:true];
}


+ (void)showStoreDetailView:(UINavigationController*)navi andStoreId:(NSString*)sid
{
    CZJStoreDetailController* storeDetail = (CZJStoreDetailController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"storeDetailVC"];
    storeDetail.storeId = sid;
    [navi pushViewController:storeDetail animated:true];
}

+ (CAShapeLayer *)creatIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    layer.position = point;
    
    return layer;
}
@end
