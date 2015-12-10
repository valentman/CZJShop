//
//  MXPullDownMenu000.h
//  MXPullDownMenu
//
//  Created by 马骁 on 14-8-21.
//  Copyright (c) 2014年 Mx. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@class MXPullDownMenu;

typedef enum
{
    IndicatorStateShow = 0,
    IndicatorStateHide
}
IndicatorStatus;

typedef enum
{
    BackGroundViewStatusShow = 0,
    BackGroundViewStatusHide
}
BackGroundViewStatus;


typedef NS_ENUM(NSInteger, CZJMXPullDownMenuType)
{
    CZJMXPullDownMenuTypeNone,                  //没有定制的情况
    CZJMXPullDownMenuTypeStore,                 //门店界面
    CZJMXPullDownMenuTypeService                //服务界面
};

@protocol MXPullDownMenuDelegate <NSObject>

- (void)PullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)pullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectCityName:(NSString*)cityName;
- (void)pullDownMenuDidSelectFiliterButton;

@end

@interface MXPullDownMenu : UIView< UITableViewDelegate,
                                    UITableViewDataSource,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegate>

- (MXPullDownMenu *)initWithArray:(NSArray *)array AndType:(CZJMXPullDownMenuType)menutype WithFrame:(CGRect)frame;
- (void)confiMenuWithSelectRow:(NSInteger)row;
- (void)setCurrentSelectedMenudIndex:(int)index;
- (void)registNotification;
- (void)removeNotificationObserve;
@property (nonatomic) id<MXPullDownMenuDelegate> delegate;

@end


// CALayerCategory
@interface CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath;

@end
