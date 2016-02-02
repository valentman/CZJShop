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
+ (BOOL)writeArrayToPlist:(NSMutableArray*)array withPlistName:(NSString*)plistName;
+ (NSMutableArray*)readArrayFromPlistWithName:(NSString*)plistName;

//---------------NSMutableDictionary数据的持久化------------------
+ (BOOL)writeDataToPlist:(NSMutableDictionary*)dict withPlistName:(NSString*)plistName;
+ (NSMutableDictionary*)readDataFromPlistWithName:(NSString*)plistName;

//----------------------启动界面信息------------------------------
+ (void)writeStarInfoDataToPlist:(NSDictionary*)dict;
+ (NSMutableDictionary*)readStartInfoPlistWithPlistName;


//-----------------------正则判断---------------------------------
+ (BOOL)isLicencePlate:(NSString *)plateNum;
+ (BOOL)isPhoneNumber:(NSString *)mobileNum;
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//------------------------UI组件设置-----------------------------
+ (UIColor *)getColorFromString:( NSString *)hexColor;
+ (void)setExtraCellLineHidden: (UITableView *)tableView;
+ (void)setSepratorColorforTableView:(UITableView *)tableView;
+ (void)hideSearchBarViewForTarget:(UIViewController*)target;    //隐藏自定义搜索栏
+ (void)customizeNavigationBarForTarget:(UIViewController*)target;   //自定义导航栏返回按钮
+ (void)customizeNavigationBarForTarget:(UIViewController *)target hiddenButton:(BOOL)hidden;
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
//----------------------------字符串处理--------------------------
+ (NSString*)getExplicitServerAPIURLPathWithSuffix:(NSString*)urlStr;
//获取字符串的Size
+ (CGSize)calculateTitleSizeWithString:(NSString *)string WithFont:(UIFont*)font;
+ (CGSize)calculateTitleSizeWithString:(NSString *)string AndFontSize:(CGFloat)fontSize;
+ (CGSize)calculateStringSizeWithString:(NSString*)string Font:(UIFont*)font Width:(CGFloat)width;
//返回带删除线的字符串
+ (NSMutableAttributedString*)stringWithDeleteLine:(NSString*)string;

//----------------------------界面控制器处理--------------------------
//从SB中获取VC
+ (UIViewController*)getViewControllerFromStoryboard:(NSString*)storyboardName andVCName:(NSString*)vcName;
//从Xib文件中获取View
+ (id)getXibViewByName:(NSString*)xibName;
//搜索界面
+ (void)showSearchView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
//登录界面和购物车界面的共通处理
+ (void)showLoginView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
+ (void)removeLoginViewFromCurrent:(UIViewController*)target;
+ (void)showShoppingCartView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
+ (void)removeShoppintCartViewFromCurrent:(UIViewController*)target ;
+ (void)removeSearchVCFromCurrent:(UIViewController*)target;
//进入详情界面
+ (void)showStoreDetailView:(UINavigationController*)navi andStoreId:(NSString*)sid;
+ (void)showGoodsServiceDetailView:(UINavigationController*)navi
                        andItemPid:(NSString*)sid
                        detailType:(CZJDetailType)detailtype;


//-----------------------------其它处理方法---------------------------
//获取时间间隔
+ (BOOL)isTimeCrossOneDay;
+ (BOOL)isTimeCrossFiveMin:(int)intervalMin;
//延迟执行Block
+ (void)performBlock:(CZJGeneralBlock)block afterDelay:(NSTimeInterval)delay;
//打印类所有方法和成员变量
+ (void)printClassMethodList:(id)target;
+ (void)printClassMemberVarible:(id)target;
//调用打电话
+ (void)callHotLine:(NSString*)phoneNum AndTarget:(id)target;
//创建字符Layer
+ (CATextLayer *)creatTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point andNumOfMenu:(int)_numOfMenu;
+ (CAShapeLayer *)creatIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point;
+ (CGRect)viewFramFromDynamic:(CZJMargin)margin size:(CGSize)viewSize index:(int)index divide:(int)divide;
@end
