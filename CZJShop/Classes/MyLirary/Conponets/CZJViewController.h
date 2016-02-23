//
//  CZJViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/22/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJNaviagtionBarView.h"


@interface CZJViewController : UIViewController<CZJViewControllerDelegate>

/*
 主要是在当前视图控制器上弹出一个视图控制器做相应的功能模块，完成之后又返回当前视图控制器.
 应用场景比如商品详情界面弹出筛选弹窗视图控制器、优惠券领取弹窗视图控制器
*/
/* 弹出窗口初始位置 */
@property (nonatomic, assign) CGRect popWindowInitialRect;
/* 弹出窗口动画后的最终位置 */
@property (nonatomic, assign) CGRect popWindowDestineRect;
/* 弹出窗口 */
@property (nonatomic, strong) UIWindow *window;
/* 背景View
 * (处于当前视图控制器顶部，弹出窗口底部，在此upView上添加一个手势监测，以便点击返回)
 */
@property (nonatomic, strong) UIView *upView;

/* 自定导航栏 */
@property (nonatomic, strong) CZJNaviagtionBarView* naviBarView;

- (void)addCZJNaviBarView:(CZJNaviBarViewType)naviBarViewType;
@end
