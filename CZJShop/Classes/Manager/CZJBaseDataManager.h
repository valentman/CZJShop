//
//  CZJBaseDataManager.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class HomeForm;
@class CZJStoreForm;
@class CZJDiscoverForm;
@class CZJCarForm;
@class CZJDetailForm;
@class CZJGoodsForm;

@interface CZJBaseDataManager : NSObject
{
    HomeForm* _homeForm;                            //首页信息
    CZJCarForm* _carForm;                           //汽车列表信息
    CZJDetailForm* _detailsForm;                    //详情信息（服务或商品）
    CZJGoodsForm* _goodsForm;                       //商品相关信息
    CZJStoreForm* _storeForm;                       //门店信息
    
    NSMutableDictionary* _discoverForms;            //发现信息
    
    NSMutableDictionary *_params;                   //post参数字典
    
}
//--------------------服务器返回数据对象模型----------------------------
@property (nonatomic, retain) HomeForm* homeForm;
@property (nonatomic, retain) CZJCarForm* carForm;
@property (nonatomic, retain) CZJStoreForm* storeForm;
@property (nonatomic, retain) CZJDetailForm* detailsForm;
@property (nonatomic, retain) NSMutableDictionary* discoverForms;
//-------------------------本地数据对象------------------------------
@property (nonatomic, assign) CLLocationCoordinate2D curLocation;
@property (nonatomic) NSMutableDictionary *params;

singleton_interface(CZJBaseDataManager);

-(void)getSomeInfoSuccess:(CZJSuccessBlock)success;


//获取首页数据
- (void)showHomeType:(CZJHomeGetDataFromServerType)dataType
                page:(int)page
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail;

//获取分类数据
- (void)showCategoryTypeId:(NSString*)typeId
                   success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail;

//获取商品列表
- (void)loadGoodsList:(NSDictionary*)postParams
                 type:(CZJHomeGetDataFromServerType)type
              success:(CZJSuccessBlock)success
                 fail:(CZJFailureBlock)failure;

//获取门店数据
- (void)showStoreWithParams:(NSDictionary*)postParams
                       type:(CZJHomeGetDataFromServerType)type
                    success:(CZJSuccessBlock)success
                       fail:(CZJFailureBlock)failure;

//获取发现数据
- (void)showDiscoverWithBlocksuccess:(CZJSuccessBlock)success fail:(CZJFailureBlock)fail;


//获取服务列表数据
- (void)showSeverciceList:(NSDictionary*)postParams
                     type:(CZJHomeGetDataFromServerType)type
                  success:(CZJSuccessBlock)success
                     fail:(CZJFailureBlock)failure;

//获取汽车品牌列表信息
- (void)getCarBrandsList;

//获取汽车品牌车系列表
- (void) loadCarSeriesWithBrandId:(NSString*)brandId
                        BrandName:(NSString*)brandName
                          Success:(CZJGeneralBlock)success
                             fail:(CZJFailureBlock)fail;
//获取汽车车型信息列表
- (void)loadCarModelSeriesId:(NSString*)seriesId
                     Success:(CZJGeneralBlock)success
                        fail:(CZJFailureBlock)fail;

//获取商品或服务详情
- (void)loadDetailsWithType:(CZJDetailType)type
            AndStoreItemPid:(NSString*)storeItemPid
                    Success:(CZJGeneralBlock)success
                       fail:(CZJFailureBlock)fail;

@end
