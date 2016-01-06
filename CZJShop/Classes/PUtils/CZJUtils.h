//
//  CZJUtils.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CZJUtils : NSObject
#pragma mark- Zhouxin
//---------------------------数据解析-----------------------------
+ (NSDictionary*)DataFromJson:(id)json;
+ (NSString*)JsonFromData:(id)data;
+ (NSData*)JsonFormData:(id)data;

//------------------NSData数据的持久化----------------------------
+ (BOOL)saveNSDataToLocal:(NSData*)data;
+ (BOOL)saveDataToLocal:(NSString*)str;
+ (NSData*)readDataFromLocal;

//---------------NSMutableArray数据的持久化-----------------------
+ (void)writeArrayToPlist:(NSMutableArray*)array withPlistName:(NSString*)plistName;
+ (NSMutableArray*)readArrayFromPlistWithName:(NSString*)plistName;

//---------------把NSMutableDictionary写入本地Plist文件------------
+ (void)writeDataToPlist:(NSMutableDictionary*)dict;
+ (void)writeStarInfoDataToPlist:(NSDictionary*)dict;
+ (void)writeDataToPlist:(NSMutableDictionary*)dict withPlistName:(NSString*)plistName;

//--------------从本地Plist文件读取到NSMutableDictionary------------
+ (NSMutableDictionary*)readDataFromPlist;
+ (NSMutableDictionary*)readStartInfoPlistWithPlistName;
+ (NSMutableDictionary*)readDataFromPlistWithName:(NSString*)plistName;

//---------------------------正则判断------------------------------
+ (BOOL)isLicencePlate:(NSString *)plateNum;
+ (BOOL)isPhoneNumber:(NSString *)mobileNum;
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//--------------------------UI组件设置-----------------------------
+ (UIColor *)getColor:( NSString *)hexColor;
+ (void)setExtraCellLineHidden: (UITableView *)tableView;
+ (void)setSCforTableView:(UITableView *)tableView;
+ (void)setNavigationBarStayleForTarget:(UIViewController*)target;
+ (void)hideSearchBarViewForTarget:(UIViewController*)target;    //隐藏自定义搜索栏
+ (void)customizeNavigationBarForTarget:(UIViewController*)target;   //自定义导航栏返回按钮
+ (void)fullScreenGestureRecognizeForTarget:(UIViewController*)currenTarget;    //自定义全屏手势返回

//---------------------------UI尺寸参数----------------------------
+ (float)xSizeScale;
+ (float)ySizeScale;
+ (CGRect)TCGRectMake:(CGRect)crt;

//----------------------------提示框------------------------------
+ (UIView*)showInfoCanvasOnTarget:(id)target action:(SEL)buttonSel;
+ (void)tipWithText:(NSString *)text andView:(UIView *)view;
+ (void)showExitAlertViewWithContent;
+ (void)showExitAlertViewWithContentOnParent:(id)parent;


#pragma mark- PJoe
+ (void)printData:(id)data;
+ (NSString*)getExplicitServerAPIURLPathWithSuffix:(NSString*)urlStr;
+ (BOOL)isTimeCrossOneDay;
+ (void)printClassMethodList:(id)target;
+ (CGSize)calculateTitleSizeWithString:(NSString *)string WithFont:(UIFont*)font;
+ (CGSize)calculateTitleSizeWithString:(NSString *)string AndFontSize:(CGFloat)fontSize;        //计算一定FontSize的字符串的长宽
+ (CGSize)calculateStringSizeWithString:(NSString*)string Font:(UIFont*)font Width:(CGFloat)width;
+ (NSMutableAttributedString*)stringWithDeleteLine:(NSString*)string;                           //返回带删除线的字符串

+ (void)showLoginView:(UIViewController*)target;
+ (void)removeLoginViewFromCurrent:(UIViewController*)target;
+ (void)showShoppingCartView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
+ (void)removeShoppintCartViewFromCurrent:(UIViewController*)target ;

+ (void)performBlock:(CZJGeneralBlock)block afterDelay:(NSTimeInterval)delay;                        //延迟执行Block
@end
