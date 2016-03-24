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
+ (NSDictionary *)dictionaryFromJsonString:(NSString *)jsonString;
+ (NSString*)JsonFromData:(id)data;
+ (NSData*)JsonFormData:(id)data;

//------------------NSData数据的持久化----------------------------
+ (BOOL)saveNSDataToLocal:(NSData*)data;
+ (BOOL)saveDataToLocal:(NSString*)str;
+ (NSData*)readDataFromLocal;

//---------------NSMutableArray数据的持久化-----------------------
+ (BOOL)writeArrayToDocumentsDirectory:(NSMutableArray*)array withPlistName:(NSString*)plistName;
+ (NSMutableArray*)readArrayFromDocumentsDirectoryWithName:(NSString*)plistName;
+ (NSMutableArray*)readArrayFromBundleDirectoryWithName:(NSString*)plistName;

//---------------NSMutableDictionary数据的持久化------------------
+ (BOOL)writeDictionaryToDocumentsDirectory:(NSMutableDictionary*)dict withPlistName:(NSString*)plistName;
+ (NSMutableDictionary*)readDictionaryFromDocumentsDirectoryWithPlistName:(NSString*)plistName;
+ (NSMutableDictionary*)readDictionaryFromBundleDirectoryWithPlistName:(NSString*)plistName;

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
+ (NSString*)cutString:(NSString*)str Prefix:(NSString*)pre;
+ (NSString*)resetString:(NSString*)str;
//获取字符串的Size
+ (CGSize)calculateTitleSizeWithString:(NSString *)string WithFont:(UIFont*)font;
+ (CGSize)calculateTitleSizeWithString:(NSString *)string AndFontSize:(CGFloat)fontSize;
+ (CGSize)calculateStringSizeWithString:(NSString*)string Font:(UIFont*)font Width:(CGFloat)width;
//返回带删除线的字符串
+ (NSMutableAttributedString*)stringWithDeleteLine:(NSString*)string;

//----------------------------界面控制器处理--------------------------
+ (void)showMyWindowOnTarget:(UIViewController*)target withMyVC:(UIViewController*)myViewController;
//从SB中获取VC
+ (UIViewController*)getViewControllerFromStoryboard:(NSString*)storyboardName andVCName:(NSString*)vcName;
//从Xib文件中获取View
+ (id)getXibViewByName:(NSString*)xibName;
//搜索界面
+ (void)showSearchView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
//登录界面和购物车界面的共通处理
+ (void)showLoginView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
+ (void)removeLoginViewFromCurrent:(UIViewController*)target;
+ (void)showCommitOrderView:(UIViewController *)target andParams:(NSArray*)_settleOrderAry;
+ (void)showShoppingCartView:(UIViewController*)target andNaviBar:(UIView*)naviBar;
+ (void)removeSearchVCFromCurrent:(UIViewController*)target;
//进入详情界面
+ (void)showStoreDetailView:(UINavigationController*)navi andStoreId:(NSString*)sid;
+ (void)showGoodsServiceDetailView:(UINavigationController*)navi
                        andItemPid:(NSString*)sid
                        detailType:(CZJDetailType)detailtype;

+ (void)showReloadAlertViewOnTarget:(UIView*)targetView withReloadHandle:(CZJGeneralBlock)reloadhandle;
+ (void)showNoDataAlertViewOnTarget:(UIView*)targetView withPromptString:(NSString*)promptStr;


//-----------------------------其它处理方法---------------------------
//获取时间间隔
+ (BOOL)isTimeCrossOneDay;
+ (BOOL)isTimeCrossFiveMin:(int)intervalMin;
+ (CZJDateTime)getLeftDatetime:(NSInteger)timeStamp;
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


//-----------------------------拍照或选取相册图片处理方法---------------------------
+ (BOOL)isCameraAvailable;
+ (BOOL)isRearCameraAvailable;
+ (BOOL)isFrontCameraAvailable;
+ (BOOL)doesCameraSupportTakingPhotos;
+ (BOOL)isPhotoLibraryAvailable;
+ (BOOL)canUserPickVideosFromPhotoLibrary;
+ (BOOL)canUserPickPhotosFromPhotoLibrary;
+ (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;


//-----------------------------------程序缓存处理---------------------------------
// 计算单个文件大小
+ (float)fileSizeAtPath:(NSString*)path;
// 计算目录大小
+ (float)folderSizeAtPath:(NSString*)path;
// 清除文件按
+ (void)clearCache:(CZJGeneralBlock)success;

//把一个数组里面的元素，重新组装成由俩个元素组成的数组的数组
+ (NSMutableArray*)getAggregationArrayFromArray:(NSArray*)sourcArray;

+ (UIView*)getBackgroundPromptViewWithPrompt:(NSString*)prompt;

@end
