//
//  CZJHomeViewManager.h
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
@interface CZJHomeViewManager : NSObject
{
    HomeForm* _homeForm;        //首页信息
    CZJCarForm* _carForm;       //汽车列表信息
    
    CZJStoreForm* _storeForm;    //门店信息
    
    NSMutableDictionary* _discoverForms;   //发现信息
    
    NSMutableDictionary *_params;       //post参数字典
    
}
@property (nonatomic, assign) CLLocationCoordinate2D curLocation;
@property (nonatomic, retain) HomeForm* homeForm;
@property (nonatomic, retain) CZJStoreForm* storeForm;
@property (nonatomic) NSMutableDictionary *params;
@property (nonatomic, retain) NSMutableDictionary* discoverForms;


singleton_interface(CZJHomeViewManager);
//获取首页数据
- (void)showHomeType:(CZJHomeGetDataFromServerType)dataType
                page:(int)page
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail;

//获取分类数据
- (void)showCategoryTypeId:(NSString*)typeId
                   success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail;

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

//获取汽车列表信息
- (void)getCarBrandsList:(CZJSuccessBlock)success
                    fail:(CZJFailureBlock)failure;

-(void)getSomeInfoSuccess:(CZJSuccessBlock)success;

@end
