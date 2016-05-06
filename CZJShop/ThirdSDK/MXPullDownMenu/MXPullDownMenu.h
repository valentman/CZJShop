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
    CZJMXPullDownMenuTypeService,               //服务列表界面
    CZJMXPullDownMenuTypeGoods,                 //商品列表界面
    CZJMXPullDownMenuTypeStoreDetail            //门店详情界面
};

@protocol MXPullDownMenuDelegate <NSObject>

@optional
- (void)PullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectRowAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)pullDownMenu:(MXPullDownMenu*)pullDownMenu didSelectCityName:(NSString*)cityName;
- (void)pullDownMenuFirstName:(NSString*)firstName andSecondName:(NSString*)secondName;
- (void)pullDownMenuDidSelectFiliterButton:(MXPullDownMenu*)pullDownMenu;     //筛选按钮
- (void)pullDownMenuDidSelectPriceButton:(MXPullDownMenu*)pullDownMenu;       //价格按钮

@end

@interface MXPullDownMenu : UIView
< UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource,
UICollectionViewDelegate
>
- (MXPullDownMenu *)initWithArray:(NSArray *)array AndType:(CZJMXPullDownMenuType)menutype WithFrame:(CGRect)frame;
- (void)storeDetailConfiMenuWithSelectRow:(NSInteger)row;
- (void)confiMenuWithSelectRow:(NSInteger)row;
- (void)tapIndexSetTitleColor:(NSInteger)tapIndex;
- (void)touchMXPullDownMenuAtMenuIndex:(NSInteger)tapIndex;
- (void)registNotification;
- (void)removeNotificationObserve;
- (NSString*)getMenuTitleByCurrentMenuIndex;
- (void)animateIndicator:(BOOL)forward;                             //商品列表界面价格单独控制小三角的翻转
@property (nonatomic) id<MXPullDownMenuDelegate> delegate;

@end


// CALayerCategory
@interface CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath;

@end
