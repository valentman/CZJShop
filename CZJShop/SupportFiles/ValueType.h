//
//  ValueType.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/9.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#ifndef CheZhiJian_ValueType_h
#define CheZhiJian_ValueType_h
@class CZJHomeViewManager;
@class CZJLoginModelManager;
@class CZJNetworkManager;

#define CZJHomeViewInstance [CZJHomeViewManager sharedCZJHomeViewManager]

#define CZJLoginModelInstance [CZJLoginModelManager sharedCZJLoginModelManager]
#define CZJNetWorkInstance [CZJNetworkManager sharedCZJNetworkManager]

typedef enum{
    eNone,
    eActivityHtml = 10,
    eRecommandHtml,
    eServiceHtml
}EWebHtmlType;

typedef enum {
    eActivity,
    eRecomment,
    eServiceItem,
    eStoreInfo,
    eShowMore
}EWEBTYPE;

typedef enum{
    eTabBarItemHome = 0,
    eTabBarItemCategory,
    eTabBarItemShop,
    eTabBarItemDiscovery,
    eTabBarItemMy
}TABBARITEMTPYE;

typedef NS_ENUM(NSUInteger, CZJButtonType) {
    CZJButtonTypeHomeScan = 1,
    CZJButtonTypeHomeShopping = 2
};

typedef NS_ENUM (NSInteger, CZJHomeGetDataFromServerType)
{
    CZJHomeGetDataFromServerTypeOne = 0,   //取得出了推荐商品之外的主页信息
    CZJHomeGetDataFromServerTypeTwo    //取得推荐商品信息
};

typedef NS_ENUM(NSInteger, CZJViewType)
{
    CZJViewTypeNaviBarView = 100
};

typedef NS_ENUM(NSInteger, CZJViewMoveOrientation)
{
    CZJViewMoveOrientationUp = 0,
    CZJViewMoveOrientationDown,
    CZJViewMoveOrientationLeft,
    CZJViewMoveOrientationRight
};

typedef void (^CZJSuccessBlock)(id json);
typedef void (^CZJFailureBlock)();
typedef void (^CZJGeneralBlock)();

#endif
