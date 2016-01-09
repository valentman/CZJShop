//  /**  统一加CZJ（车之健）前缀 **/
//  CZJDefinition.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#ifndef CZJDefinition_h
#define CZJDefinition_h

//----------------------------服务器接口-------------------------------
//服务地址
static NSString *const kCZJServerAddr = @"http://192.168.0.251:8080/appserver/";
//static NSString *const kCZJServerAddr = @"http://m.chezhijian.com/appserver/";

//首页接口组
static NSString *const kCZJServerAPIShowHome = @"chezhu/showHomeV2.do";                             //获取首页数据
static NSString *const kCZJServerAPIGetRecoGoods = @"chezhu/showRecommendGoods.do";                 //获取首页推荐商品
//static NSString *const kCZJServerAPIActivityCenter = @"chezhu/showActivityCenter.do";               //获取活动中心信息
//static NSString *const kCZJServerAPICarInfo = @"chezhu/URLshowCarNews.do";                          //获取汽车资讯
static NSString *const kCZJServerAPILoadCarBrands = @"chezhu/loadCarBrandsV2.do";                   //获取汽车品牌列表
static NSString *const kCZJServerAPILoadCarSeries = @"chezhu/loadCarSeries.do";                     //获取汽车品牌车系列表
static NSString *const kCZJServerAPILoadCarModels = @"chezhu/loadCarModels.do";                     //获取汽车品牌车系列表
static NSString *const kCZJServerAPIServiceDetail = @"chezhu/showServiceItemDetail.do";             //获取服务详情
static NSString *const kCZJServerAPIServicePicDetail = @"chezhu/showServicePicDetail.do";           //获取服务图文详情
static NSString *const kCZJServerAPIServiceBuyNoteDetail = @"chezhu/showServiceNoteDetail.do";      //获取服务购买须知详情
static NSString *const kCZJServerAPIServiceCarModelsList = @"chezhu/showServiceCarModels.do";       //获取服务适用车型详情
static NSString *const kCZJServerAPIServiceHotReco = @"chezhu/searchHotRecommend.do";               //获取服务热门推荐
static NSString *const kCZJServerAPICommentsList = @"chezhu/loadEvaluations.do";                    //获取评论列表
static NSString *const kCZJServerAPIReplyList = @"chezhu/loadEvalReplys.do";                        //获取回复列表

//分类接口组
static NSString *const kCZJServerAPIGetCategoryData= @"chezhu/loadGoodsSubTypes.do";                //获取分类信息
static NSString *const kCZJServerAPIGoodsList = @"chezhu/searchGoods.do";                           //获取商品列表
static NSString *const kCZJServerAPIGoodsDetail = @"chezhu/showGoodsDetail.do";                     //获取商品图文详情
static NSString *const kCZJServerAPIGoodsSKU = @"chezhu/loadGoodsSkus.do";                          //获取的sku数据
static NSString *const kCZJServerAPIGoodsHotReco = @"chezhu/loadStoreRecommends.do";                //获取商品热门推荐
static NSString *const kCZJServerAPIGoodsFilterList = @"chezhu/loadGoodsTypeAttrs.do";              //获取筛选列表
static NSString *const kCZJServerAPIGoodsPriceList = @"chezhu/loadGoodsTypePrices.do";              //获取商品价格列表
static NSString *const kCZJServerAPIGoodsBrandsList = @"chezhu/loadGoodsTypeBrands.do";             //获取商品品牌列表
static NSString *const kCZJServerAPIGoodsPicDetails = @"chezhu/showGoodsPicDetail.do";              //获取商品图文详情
static NSString *const kCZJServerAPIGoodsBuyNoteDetail = @"chezhu/showGoodsNoteDetail.do";          //获取商品购买须知详情
static NSString *const kCZJServerAPIGoodsAfterSaleDetail = @"chezhu/showGoodsAfterSale.do";         //获取商品售后详情
static NSString *const kCZJServerAPIGoodsCarModelList = @"chezhu/showGoodsCarModels.do";            //获取商品适用车型

//门店接口组
static NSString *const kCZJServerAPIGetNearbyStores = @"chezhu/loadStores.do";                      //获取附近门店列表
static NSString *const kCZJServerAPIGetCitys = @"chezhu/loadO2oCitys.do";                           //获取城市列表
//static NSString *const kCZJServerAPIGetNearbyStoresMap = @"chezhu/loadMapStores.do";                //获取附近门店地图列表
static NSString *const kCZJServerAPIGetServiceList = @"chezhu/searchServiceItemV2.do";              //获取附近门店服务列表

//发现接口组
static NSString *const kCZJServerAPIGetDiscovery = @"chezhu/loadDiscoveryInfo.do";                  //获取发现数据

//我的信息接口组
static NSString *const kCZJServerAPILoginSendVerifiCode = @"chezhu/sendLogonCode.do";               //发送登录验证码
static NSString *const kCZJServerAPILoginInByVerifiCode = @"chezhu/logonByCode.do";                 //验证码登录
static NSString *const kCZJServerAPILoginInByPassword= @"chezhu/logonByPasswd.do";                  //密码登录
static NSString *const kCZJServerAPIRegisterSetPassword = @"chezhu/resetPasswdV2.do";               //注册设置密码

//订单购物接口组
static NSString *const kCZJServerAPIAddToShoppingCart= @"chezhu/addShoppingCartItem.do";            //加入购物车
static NSString *const kCZJServerAPIShoppingCartCount = @"chezhu/countShoppingCart.do";             //读取购物车数量
static NSString *const kCZJServerAPIStoreCoupons = @"chezhu/showStoreCoupons.do";                   //获取优惠券列表
static NSString *const kCZJServerAPITakeCoupon = @"chezhu/takeCouponV2.do";                         //领取优惠券
static NSString *const kCZJServerAPIShoppingCartList = @"chezhu/loadShoppingCart.do";               //获取购物车信息
static NSString *const kCZJServerAPIDeleteShoppingCartInfo = @"chezhu/deleteShoppingCart.do";       //删除购物车信息
static NSString *const kCZJServerAPISettleOrders = @"chezhu/settleOrder.do";                        //去结算
static NSString *const kCZJServerAPIGetUseableCouponList = @"chezhu/showCouponsForOrder.do";        //获取能使用的优惠券列表(storeIds)
//static NSString *const kCZJServerAPIGetSetupStoreList = @"chezhu/loadSetupStores.do";               //获取安装门店列表
static NSString *const kCZJServerAPIAddAddr = @"chezhu/addAddrV2.do";                               //添加地址
static NSString *const kCZJServerAPIGetAddrList = @"chezhu/loadAddrsV2.do";                         //获取地址列表
static NSString *const kCZJServerAPIRemoveAddr = @"chezhu/removeAddrV2.do";                         //删除地址 (id)
static NSString *const kCZJServerAPISetDefaultAddr = @"chezhu/setDftAddrV2.do";                     //设置默认地址 (id)
static NSString *const kCZJServerAPIUpdateAddr = @"chezhu/updateAddrV2.do";                         //修改地址


//门店详情接口组
//static NSString *const kCZJServerAPIGetStoreDetail = @"chezhu/showStoreDetail.do";                  //获取门店详情
//static NSString *const kCZJServerAPILoadGoodsInStore = @"chezhu/loadStoreGoods.do";                 //获取门店下面的服务和商品
//static NSString *const kCZJServerAPIAttentionStore = @"chezhu/attentionStore.do";                   //关注门店
//static NSString *const kCZJServerAPICancelAttentionStore = @"chezhu/cancelAttentionStore.do";       //取消关注门店
//static NSString *const kCZJServerAPIAttentaionGoods = @"chezhu/attentionGoods.do";                  //关注商品
//static NSString *const kCZJServerAPICancleAttentionGoods = @"chezhu/cancelAttentionGoods.do";       //取消关注商品
//static NSString *const kCZJServerAPILoadOtherStoreList = @"chezhu/loadOtherStores.do";              //其他门店列表
//static NSString *const kCZJServerAPILoadServiceTypes = @"chezhu/loadServiceTypes.do";               //得到服务分类



//-----------------------系统常量定义---------------------------
//在应用商店中本APP的地址
static NSString *const kCZJAPPURL = @"https://itunes.apple.com/us/app/id1035567397";

//第三方推送服务方申请的AppID和AppKey,暂时使用信鸽的。
static uint32_t const kCZJPushServerAppId = 2200145103;
static NSString *const kCZJPushServerAppKey = @"I18QP9TZB66R";

//分享设置ID
static NSString *const kCZJOpenShareQQAppId = @"1104733921";
static NSString *const kCZJOpenShareWeiboAppKey = @"1958823046";
static NSString *const kCZJOpenShareWeixinAppId = @"wxe3d6ba717d704a6e";


//----------------------本地Plist文件名
static NSString *const kCZJPlistFileCitys = @"Citys.plist";                                 //城市列表文件
static NSString *const kCZJPlistFileCheckVersion = @"checkVersion.plist";                   //版本检测信息文件
static NSString *const kCZJPlistFileStartInfo = @"StartInfo.plist";                         //开始界面信息文件
static NSString *const kCZJPlistFileMessage = @"Message.plist";                             //信息管理文件


//----------------------UserDefault键名定义
static NSString *const kUserDefaultTime = @"userdefaultTime";
static NSString *const kUserDefaultServiceTypeID = @"userdefaultserviceyypeid";             //服务项目ID
static NSString *const kUserDefaultChoosedCarType = @"userdefaultchoosedcar";               //筛选是选择的车型名称
static NSString *const kUserDefaultServicePlace = @"userdefaultserviceplace";               //上门服务
static NSString *const kUserDefaultDetailStoreItemPid = @"DetailStoreItemPid";              //详情界面storeitemPid
static NSString *const kUserDefaultDetailItemCode = @"DetailItemCode";                      //详情界面Itemcode
static NSString *const kUserDefaultShoppingCartCount = @"ShoppingCartCount";                //购物车数量



//-----------------------常用字符常量定义---------------------------
//登录信息
static NSString *const kCZJUserName = @"userName";
static NSString *const kCZJIsFirstLogin = @"isFirstLogin";
static NSString *const kCZJIsUserHaveLogined = @"isHaveLogined";

//城市定位
static NSString *const kCZJDefaultCityID = @"defaultyCityId";
static NSString *const kCZJDefaultyCityName = @"defaultyCityName";
static NSString *const kCZJDefaultyAddr = @"defaultyAddress";
static NSString *const kCZJChengdu = @"成都市";
static NSString *const kCZJChengduID = @"469";
static NSString *const kCZJMaptoStoreWeb = @"mapToStoreWeb";

//Alert提示字符串
static NSString *const kCZJTitle = @"提示";
static NSString *const kCZJMessageUpdate = @"您需去应用商店更新版本，否则将无法正常使用";
static NSString *const kCZJMessageNet = @"网络异常，请确认当前网络是否连接。";
static NSString *const kCZJConfirmUpdateTitle = @"更新";
static NSString *const kCZJConfirmTitle = @"确定";
static NSString *const kCZJCancelTitle = @"取消";

//版本检测
static NSString *const kCZJCheckVersion = @"checkVersion";
static NSString *const kCZJEnfore = @"enforce";
static NSString *const kCZJNetVersion = @"version";
static NSString *const kCZJCurVerson = @"CFBundleShortVersionString";


static NSString *const kCZJUserRegisterCode = @"userRegisterCode";
static NSString *const kCZJRefreshMyCarList = @"refreshMyCarList";
static NSString *const kCZJRefreshMyAddrList = @"refreshMyAddrList";
static NSString *const kCZJAddAddressSelectCity = @"currentSelectCity";
static NSString *const kCZJMapToStoreWeb = @"mapToStoreWeb";
static NSString *const kCZJChangeCurCityName = @"changeCurCityName";
static NSString *const kCZJRefreshNewData = @"refreshNewData";
static NSString *const kCZJRefreshActiveData = @"refreshActiveData";
static NSString *const kCZJChangeHotCity = @"changeHotCity";
static NSString *const kCZJRefreshMyForms = @"refreshMyForms";
static NSString *const kCZJAlipaySuccseful = @"alipaySuccseful";
static NSString *const kCZJShowServiceList = @"showServiceList";
static NSString *const kCZJIsFirstStart = @"isFirstStart" ;
static NSString *const kCZJRefreshNearCityData = @"refreshNearCityData";




//-----------------------Notification常量定义---------------------------
static NSString *const kCZJNotifiRefreshDetailView = @"refreshDetailView";
static NSString *const kCZJNotifiPicDetailBack = @"PicDetailBack";


//-----------------------StoryBoardID常量定义---------------------------
static NSString *const kCZJStoryBoardFileMain = @"Main";
static NSString *const kCZJStoryBoardFileLogin = @"Login";
static NSString *const kCZJStoryBoardIDHomeView = @"homeViewSBID";
static NSString *const kCZJStoryBoardIDStartPage = @"startPageSBID";


//-----------------------CollectionViewCellIdentifier常量定义---------------------------
static NSString *const kCZJCollectionCellReuseIdMiaoSha = @"CZJMiaoShaCollectionCell";
static NSString *const kCZJCollectionCellReuseIdLimit = @"CZJLimitCollectionCell";
static NSString *const kCZJCollectionCellReuseIdGoodReco = @"CZJGoodsRecoCollectionCell";


#endif /* CZJDefinition_h */


