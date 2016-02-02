//
//  CZJStarRageView.h
//  CZJShop
//
//  Created by Joe.Pen on 2/2/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DEFAULT_DURATION 0.5

@class CZJStarRageView;
@protocol CZJStarRateViewDelegate <NSObject>

/**
 *  通知代理改变评分到某一特定的值
 *
 *  @param starRateView 指当前评分view
 *  @param percentage   新的评分值
 */
- (void)starRateView:(CZJStarRageView *)starRateView didChangedScorePercentageTo:(CGFloat)percentage;

@end

@interface CZJStarRageView : UIView

/**
 *  代理
 */
@property (weak, nonatomic) id<CZJStarRateViewDelegate> delegate;
/**
 *  是否使用动画，默认为NO
 */
@property (assign, nonatomic) BOOL shouldUseAnimation;
/**
 *  是否允许非整型评分，默认为NO
 */
@property (assign, nonatomic) BOOL allowIncompleteStar;
/**
 *  是否允许用户手指操作评分,默认为YES
 */
@property (assign, nonatomic) BOOL allowUserInteraction;
/**
 *  当前评分值，范围0---1，表示的是黄色星星占的百分比,默认为1
 */
@property (assign, nonatomic) CGFloat percentage;

/**
 *  初始化方法，需传入评分星星的总数
 *
 *  @param frame 该starView的大小与位置
 *  @param count 评分星星的数量
 *
 *  @return 实例变量
 */

@property (assign, nonatomic)NSInteger starCount;

@property (assign, nonatomic)CGFloat starWidth;

@property (strong, nonatomic)UIView* lightStarView;

@property (strong, nonatomic)UIView* grayStarView;

@property (strong, nonatomic)UIPanGestureRecognizer* pan;


- (id)initWithFrame:(CGRect)frame starCount:(NSInteger)count;
/**
 *  设置当前评分为某一值,是否使用动画取决于shouldUseAnimation属性的取值
 *
 *  @param score 新的评分值
 */
- (void)setScore:(CGFloat)score;

@end
