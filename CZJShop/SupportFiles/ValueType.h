//
//  ValueType.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/9.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#ifndef CheZhiJian_ValueType_h
#define CheZhiJian_ValueType_h
@class CZJBaseDataManager;
@class CZJLoginModelManager;
@class CZJNetworkManager;

#define CZJBaseDataInstance [CZJBaseDataManager sharedCZJBaseDataManager]

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
    CZJButtonTypeHomeScan = 1,              //导航栏上扫一扫按钮
    CZJButtonTypeHomeShopping = 2,          //导航栏上购物车按钮
    CZJButtonTypeNaviBarBack,               //导航栏上返回上一页按钮
    CZJButtonTypeNaviBarMore,                  //导航栏上详情界面更多按钮
};

typedef NS_ENUM (NSInteger, CZJHomeGetDataFromServerType)
{
    CZJHomeGetDataFromServerTypeOne = 0,    //取得除了推荐商品之外的主页信息  *刷新
    CZJHomeGetDataFromServerTypeTwo         //取得推荐商品信息              *记载更多
};

typedef NS_ENUM(NSInteger, CZJViewType)
{
    CZJViewTypeNaviBarView = 100,           //主页导航栏
    CZJViewTypeNaviBarViewBack,             //一般界面带返回按钮导航栏
    CZJViewTypeNaviBarViewCategory,         //分类界面导航栏
    CZJViewTypeNaviBarViewDetail            //详情界面导航栏
};

typedef NS_ENUM(NSInteger, CZJViewMoveOrientation)
{
    CZJViewMoveOrientationUp = 0,
    CZJViewMoveOrientationDown,
    CZJViewMoveOrientationLeft,
    CZJViewMoveOrientationRight
};

//详情类型（商品详情、服务详情）
typedef NS_ENUM(NSInteger, CZJDetailType)
{
    CZJDetailTypeService,
    CZJDetailTypeGoods
};

typedef void (^CZJSuccessBlock)(id json);
typedef void (^CZJFailureBlock)();
typedef void (^CZJGeneralBlock)();

#endif
