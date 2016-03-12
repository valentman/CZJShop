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
    CZJButtonTypeSearchBar,                 //导航栏上搜索按钮
    CZJButtonTypeNaviBarBack,               //导航栏上返回上一页按钮
    CZJButtonTypeNaviBarMore,               //导航栏上详情界面更多按钮
    CZJButtonTypeNaviArrange,                //导航栏上列表排列按钮
    CZJButtonTypeMap
};

typedef NS_ENUM (NSInteger, CZJHomeGetDataFromServerType)
{
    CZJHomeGetDataFromServerTypeOne = 0,    //取得除了推荐商品之外的主页信息  *刷新
    CZJHomeGetDataFromServerTypeTwo         //取得推荐商品信息              *加载更多
};

typedef NS_ENUM(NSInteger, CZJNaviBarViewType)
{
    CZJNaviBarViewTypeHome = 100,       //主页导航栏
    CZJNaviBarViewTypeBack,             //一般界面带返回按钮导航栏
    CZJNaviBarViewTypeCategory,         //分类界面导航栏
    CZJNaviBarViewTypeDetail,           //详情界面导航栏
    CZJNaviBarViewTypeStoreDetail,      //门店详情导航栏
    CZJNaviBarViewTypeGoodsList,        //商品列表界面导航栏
    CZJNaviBarViewTypeMain,             //主界面导航栏
    CZJNaviBarViewTypeGeneral,          //仿系统导航栏
    CZJNaviBarViewTypeScan              //扫描界面导航栏
};

typedef NS_ENUM(NSInteger, CZJViewMoveOrientation)
{
    CZJViewMoveOrientationUp = 0,
    CZJViewMoveOrientationDown,
    CZJViewMoveOrientationLeft,
    CZJViewMoveOrientationRight
};

//详情类型（商品详情、服务详情、门店详情）
typedef NS_ENUM(NSInteger, CZJDetailType)
{
    CZJDetailTypeGoods = 0,
    CZJDetailTypeService,
    CZJDetailTypeStore
};

//商品类型（一般商品、爆款商品、秒杀商品）
typedef NS_ENUM(NSInteger, CZJGoodsPromotionType)
{
    CZJGoodsPromotionTypeGeneral = 0,
    CZJGoodsPromotionTypeBaoKuan,
    CZJGoodsPromotionTypeMiaoSha
};

//评论类型
typedef NS_ENUM(NSInteger, CZJEvalutionType)
{
    CZJEvalutionTypeAll = 0,
    CZJEvalutionTypePic = 1,
    CZJEvalutionTypeGood = 2,
    CZJEvalutionTypeMiddle = 3,
    CZJEvalutionTypeBad = 4
};

//退换货列表类型（可退换货，已退换货）
typedef NS_ENUM(NSInteger, CZJReturnListType)
{
    CZJReturnListTypeReturned = 0,
    CZJReturnListTypeReturnable
};

typedef NS_ENUM(NSInteger, CZJCarListType)
{
    CZJCarListTypeFilter = 0,
    CZJCarListTypeGeneral
};

//CEll类型（订单页面展开Cell，详情界面上拉图文详情Cell）
typedef NS_ENUM(NSInteger, CZJCellType)
{
    CZJCellTypeDetail = 100,
    CZJCellTypeExpand
};

//订单详情页面类型（一般订单详情界面，退换货订单详情界面）
typedef NS_ENUM(NSInteger, CZJOrderDetailType)
{
    CZJOrderDetailTypeGeneral = 100,
    CZJOrderDetailTypeReturned
};


struct CZJMargin {
    CGFloat horisideMargin;
    CGFloat vertiMiddleMargin;
};
typedef struct CZJMargin CZJMargin;


struct CZJDateTime
{
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
};
typedef struct CZJDateTime CZJDateTime;


CG_INLINE CZJMargin CZJMarginMake(CGFloat horisideMargin, CGFloat vertiMiddleMargin)
{
    CZJMargin margin;
    margin.horisideMargin = horisideMargin;
    margin.vertiMiddleMargin = vertiMiddleMargin;
    return margin;
}

typedef void (^MGBasicBlock)();
typedef void (^CZJButtonBlock)(UIButton* button);
typedef void (^CZJSuccessBlock)(id json);
typedef void (^CZJFailureBlock)();
typedef void (^CZJGeneralBlock)();

#endif
