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

+(NSData*)JsonFormData:(id)data{
    
    NSError* error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    return jsonData;
}


#pragma mark- 数据持久化
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
+ (void)writeArrayToPlist:(NSMutableArray*)array withPlistName:(NSString*)plistName{
    NSString *plistPath = [PJDocumentsPath stringByAppendingPathComponent:plistName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:plistPath];
    if (!isExists) {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    [array writeToFile:plistPath atomically:YES];
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


#pragma mark 把可变字典数据写入本地Plist文件
+ (void)writeDataToPlist:(NSMutableDictionary*)dict{
    [self writeDataToPlist:dict withPlistName:@"Message.plist"];
}

+ (void)writeStarInfoDataToPlist:(NSDictionary*)dict{
    [self writeDataToPlist:[dict mutableCopy] withPlistName:kCZJPlistFileStartInfo];
}

+ (void)writeDataToPlist:(NSMutableDictionary*)dict withPlistName:(NSString*)plistName
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
        [plistData writeToFile:plistPath atomically:YES];
    }
}


#pragma mark 从本地Plist文件读取到可变字典
+ (NSMutableDictionary*)readDataFromPlist{
    return [self readDataFromPlistWithName:@"Message.plist"];
}

+ (NSMutableDictionary*)readStartInfoPlistWithPlistName
{
    return [self readDataFromPlistWithName:kCZJPlistFileStartInfo];
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


#pragma mark- 正则判断
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


#pragma mark- UI组件设置
+( UIColor *) getColor:( NSString *)hexColor
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

+ (void)setSCforTableView:(UITableView *)tableView{
    tableView.separatorColor = RGBACOLOR(230.0f, 230.0f, 230.0f, 1.0f);
}

+ (void)setExtraCellLineHidden: (UITableView *)tableView{
    tableView.separatorColor = RGBACOLOR(230.0f, 230.0f, 230.0f, 1.0f);
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
    
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

+(void)setNavigationBarStayleForTarget:(UIViewController*)target{
    [target.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:48/255.0
                                                                               green:165/255.0
                                                                                blue:193/255.0
                                                                               alpha:0.5]];
    
    
    [target.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    [target.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    target.navigationItem.backBarButtonItem = backItem;
}

+ (void)hideSearchBarViewForTarget:(UIViewController*)target
{
    UINavigationBar* bar =  target.navigationController.navigationBar;
    [bar setBackgroundColor:RGBA(240, 16, 35, 0.0)];
    NSArray* _barSubViews = [bar subviews];
    for (id object in _barSubViews) {
        if ([object tag] == CZJViewTypeNaviBarView)
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
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBtn addTarget:target action:@selector(backLastView) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 60, 40);
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    target.navigationItem.leftBarButtonItem = leftItem;
    target.navigationController.interactivePopGestureRecognizer.delegate = (id)target;
    class_addMethod([target class],@selector(backLastView),(IMP)backLastView,"v@:");    //动态的给类添加一个方法
}


- (void)fullScreenGestureRecognizeForTarget:(UIViewController*)currenTarget
{
    currenTarget.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    id target = currenTarget.navigationController.interactivePopGestureRecognizer.delegate;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = target;
    [currenTarget.view addGestureRecognizer:pan];
    currenTarget.navigationController.interactivePopGestureRecognizer.enabled = NO;

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark- Frames
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


#pragma mark- 提示框
+(void)tipWithText:(NSString *)text andView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud setYOffset:PJ_SCREEN_HEIGHT/4];
    [hud hide:YES afterDelay:1];
}

+ (UIView*)showInfoCanvasOnTarget:(id)target action:(SEL)buttonSel{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, (PJ_SCREEN_HEIGHT-100)/2, PJ_SCREEN_WIDTH, 200)];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_icon_noweb.png"]];
    image.frame = CGRectMake((PJ_SCREEN_WIDTH - 60)/2,0, 60, 60);
    [view addSubview:image];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, PJ_SCREEN_WIDTH, 24)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont boldSystemFontOfSize:14];
    lab.textColor = RGBACOLOR(51, 51, 51, 1);
    lab.text = @"网络异常，请确认当前网络是否连接";
    [view addSubview:lab];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - 60)/2, 104, 60, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR(255, 0, 0, 255) forState:UIControlStateNormal];
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
+ (void)printData:(id)data
{
    NSDictionary* printDic = [self DataFromJson:data];
    
    NSLog(@"%@",[printDic description]);
}

#pragma mark- 字符串处理
+ (NSString*)getExplicitServerAPIURLPathWithSuffix:(NSString*)urlStr{
    return [NSString stringWithFormat:@"%@%@",kCZJServerAddr,urlStr];
}

+ (BOOL)isTimeCrossOneDay
{
    //此处只在第一次进入程序或启动时间超过一天才更新地区信息
    UInt64 currentTime = [[NSDate date] timeIntervalSince1970];     //当前时间
    UInt64 lastUpdateTime = [[USER_DEFAULT valueForKey:kUserDefaultTime] longLongValue];   //上次更新时间
    UInt64 intervalTime = currentTime - lastUpdateTime;
    if (0 == currentTime ||
        intervalTime > 86400)
    {
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%llu",currentTime] forKey:kUserDefaultTime];
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


@end
