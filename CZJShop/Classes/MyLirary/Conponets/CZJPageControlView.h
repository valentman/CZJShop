//
//  CZJPageControlView.h
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPagePicDetail 0
#define kPageNotice 1
#define kPageAfterSale 2
#define kPageAplicable 3
@class CZJPageControlViewConfig;

@interface CZJPageControlView : UIView
@property (nonatomic, retain) CZJPageControlViewConfig* pageControlViewConfig;
- (instancetype)initWithFrame:(CGRect)frame andPageIndex:(NSInteger)pageIndex;
- (void)setTitleArray:(NSArray*)titleArray andVCArray:(NSArray*)vcArray;
- (void)changeControllerClick:(id)sender;
@end

#define kGeneralPageControllerFrame CGRectMake(0, 50, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - 50)
#define kGeneralPageControllerBtnTitleColorNormal [UIColor darkGrayColor]
#define kGeneralPageControllerBtnTitleColorSelectd CZJREDCOLOR
/**
 *  PageControlView的配置文件
 */
@interface CZJPageControlViewConfig : NSObject

/**
 *  pageController的Frame
 */
@property (nonatomic)CGRect pageControllerFrame;
/**
 *  pageController的背景颜色
 */
@property (nonatomic)UIColor* pageControllerBGColor;

/**
 * pageController导航按钮标题颜色（正常）
 */
@property (nonatomic)UIColor* btnTitleColorNormal;
/**
 * pageController导航按钮标题颜色（选中）
 */
@property (nonatomic)UIColor* btnTitleColorSelected;
/**
 * pageController导航按钮背景颜色
 */
@property (nonatomic)UIColor* btnBackgroundColor;
/**
 *
 */
@property (nonatomic)float btnTitleLabelSize;
@end