//
//  CZJDefinition.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#ifndef CZJDefinition_h
#define CZJDefinition_h

/**  统一加CZJ前缀 **/
//-----------------------系统常量定义---------------------------
static NSString *const kCZJServerAddr = @"http://192.168.0.251:8080/appserver/";
//static NSString *const kCZJServerAddr = @"http://m.chezhijian.com/appserver/";

//----------------------------服务器接口-------------------------------
static NSString *const kCZJServerAPIShowHome = @"chezhu/showHomeV2.do";                     //获取首页数据
static NSString *const kCZJServerAPIGetRecoGoods = @"chezhu/showRecommendGoods.do";         //获取首页推荐商品
static NSString *const kCZJServerAPIActivityCenter = @"chezhu/showActivityCenter.do";       //获取活动中心信息
static NSString *const kCZJServerAPICarInfo = @"chezhu/URLshowCarNews.do";                  //获取汽车资讯
static NSString *const kCZJServerAPILoadCarBrands = @"chezhu/loadCarBrandsV2.do";           //获取汽车品牌列表

static NSString *const kCZJServerAPIGetCategoryData= @"chezhu/loadGoodsSubTypes.do";        //获取分类信息

static NSString *const kCZJServerAPIGetNearbyStores = @"chezhu/loadNearbyStoresV2.do";      //获取附近门店列表
static NSString *const kCZJServerAPIGetCitys = @"chezhu/loadO2oCitys.do";                   //获取城市列表
static NSString *const kCZJServerAPIGetNearbyStoresMap = @"chezhu/loadMapStores.do";        //获取附近门店地图列表
static NSString *const kCZJServerAPIGetServiceList = @"chezhu/searchServiceItemV2.do";      //获取附近门店服务列表

static NSString *const kCZJServerAPIGetDiscovery = @"chezhu/loadDiscoveryInfo.do";          //获取发现数据


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
static NSString *const kCZJPlistFileCitys = @"Citys.plist";                 //城市列表文件
static NSString *const kCZJPlistFileCheckVersion = @"checkVersion.plist";    //版本检测信息文件
static NSString *const kCZJPlistFileStartInfo = @"StartInfo.plist";           //开始界面信息文件
static NSString *const kCZJPlistFileMessage = @"Message.plist";                 //信息管理文件


//----------------------UserDefault键名定义
static NSString *const  kUserDefaultTime = @"userdefaultTime";


//-----------------------常用字符常量定义---------------------------
//城市定位
static NSString *const kCZJIsUserHaveLogined = @"isHaveLogined";
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

static NSString *const kCZJIsFirstLogin = @"isFirstLogin";
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
static NSString *const kCZJUserName = @"userName";


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


