  //
//  CZJHomeViewManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJBaseDataManager.h"
#import "CZJNetworkManager.h"
#import "WGS84TOGCJ02.h"
#import "CZJLoginModelManager.h"
#import "CZJErrorCodeManager.h"
#import "CCLocationManager.h"
#import "ZXLocationManager.h"
#import "HomeForm.h"
#import "CZJStoreForm.h"
#import "CZJCarForm.h"
#import "CZJDetailForm.h"
#import "CZJGoodsForm.h"
#import "CZJShoppingCartForm.h"
#import "CZJOrderForm.h"
#import "UserBaseForm.h"
@implementation CZJBaseDataManager
#pragma mark- synthesize
@synthesize curLocation =  _curLocation;
@synthesize homeForm = _homeForm;
@synthesize carForm = _carForm;
@synthesize storeForm = _storeForm;
@synthesize params = _params;
@synthesize goodsForm = _goodsForm;
@synthesize shoppingCartForm = _shoppingCartForm;
@synthesize discoverForms = _discoverForms;
@synthesize goodsTypesAry = _goodsTypesAry;
@synthesize serviceTypesAry = _serviceTypesAry;
@synthesize carBrandForm = _carBrandForm;
@synthesize carModealForm = _carModealForm;
@synthesize carSerialForm = _carSerialForm;
@synthesize orderPaymentTypeAry = _orderPaymentTypeAry;

#pragma mark- implement
singleton_implementation(CZJBaseDataManager);

- (id) init
{
    if (self = [super init])
    {
        _params = [NSMutableDictionary alloc];
        _discoverForms = [NSMutableDictionary dictionary];
        _orderStoreCouponAry = [NSMutableArray array];
        _serviceTypesAry = [NSMutableArray array];
        _goodsTypesAry = [NSMutableArray array];
        _orderPaymentTypeAry = [NSArray array];
        [self initParameters];
        [self getAreaInfos];
        
        NSArray* dict = [CZJUtils readArrayFromBundleDirectoryWithName:@"PaymentType"];
        _orderPaymentTypeAry = [CZJOrderTypeForm objectArrayWithKeyValuesArray:dict];
        return self;
    }
    return nil;
}

- (void)initParameters
{
    //固定请求参数确定
    NSDictionary* _tmpparams = @{@"chezhuId" : nil == [CZJLoginModelInstance cheZhuId] ? @"0" : [CZJLoginModelInstance cheZhuId],
                                 @"cityId" : nil == [CZJLoginModelInstance cityId] ? @"0" : [CZJLoginModelInstance cityId],
                                 @"chezhuMobile" : nil == [CZJLoginModelInstance mobile] ? @"0" : [CZJLoginModelInstance mobile],
                                 @"lng" : @(_curLocation.longitude),
                                 @"lat" : @(_curLocation.latitude),
                                 @"os" : @"ios",
                                 @"suffix" : ((iPhone6Plus || iPhone6) ? @"@3x" : @"@2x")
                                 };
    _params = [_tmpparams mutableCopy];
}

- (NSArray*)orderPaymentTypeAry
{
    for (CZJOrderTypeForm* form in _orderPaymentTypeAry)
    {
        form.isSelect = NO;
        if ([form.orderTypeName isEqualToString:@"支付宝"])
        {
            form.isSelect = YES;
        }
    }
    return _orderPaymentTypeAry;
}

- (void)refreshChezhuID:(NSString*)chezhuID
{
    [_params setValue:chezhuID forKey:@"chezhuId"];
}


- (void)setCurLocation:(CLLocationCoordinate2D)curLocation
{
    if (![WGS84TOGCJ02 isLocationOutOfChina:curLocation])
    {
        CLLocationCoordinate2D coord = [WGS84TOGCJ02 transformFromWGSToGCJ:curLocation];
        _curLocation = coord;
    }
    else
    {
        _curLocation = curLocation;
    }
    [self initParameters];
}

- (void)setCurCityName:(NSString *)curCity
{
    if (curCity)
    {
        [self generalPost:@{@"cityName":curCity} success:^(id json) {
            NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            self.curCityID = [dict valueForKey:@"cityId"];
            self.curProvinceID = [dict valueForKey:@"provinceId"];
            [self initParameters];
        } andServerAPI:kCZJServerAPIGetCityIdByName];
    }
}

- (BOOL)showAlertView:(id)info{
    NSDictionary* dict = [CZJUtils DataFromJson:info];
    NSString* msgKey = [[dict valueForKey:@"code"] stringValue];
    if (![msgKey isEqual:@"0"]) {
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowErrorInfoWithErrorCode:msgKey];
        return NO;
    }
    DLog(@"网络返回数据：%@", [dict description]);
    return YES;
}


- (void)getAreaInfos
{
    CZJSuccessBlock successBlock = ^(id json) {
        if ([self showAlertView:json])
        {
            NSDictionary* newdict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            if (_storeForm)
            {
                [_storeForm setNewProvinceDataWithDictionary:newdict];
            }
            else
            {
                _storeForm = [[CZJStoreForm alloc]initWithDictionary:newdict];
                [_storeForm setNewProvinceDataWithDictionary:newdict];
            }
        }
    };

    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetCitys
                             parameters:_params
                                success:successBlock
                                   fail:^{}];
}


-(void)getSomeInfoSuccess:(CZJSuccessBlock)success{
    NSString* tst = [[CZJLoginModelInstance  cheZhuId] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString* str = [NSString stringWithFormat:@"{\"chezhuId\":\"%@\",\"cityId\":\"%@\",\"mobile\":\"%@\",\"lat\":\"%@\",\"lng\":\"%@\"}",tst,[CZJLoginModelInstance cityId],[CZJLoginModelInstance mobile],[NSNumber numberWithDouble:_curLocation.latitude],[NSNumber numberWithDouble:_curLocation.longitude]];
    success(str);
}


#pragma mark- 首页
- (void)showHomeType:(CZJHomeGetDataFromServerType)dataType
                page:(int)page
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail;
{
    __block CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            if (dataType == CZJHomeGetDataFromServerTypeOne)
            {
                [_homeForm cleanData];//刷新则清空主页数据,京东也是这样的
                if (_homeForm)
                {
                    [_homeForm setNewDictionary:[CZJUtils DataFromJson:json]];
                }
                else
                {
                    _homeForm = [[HomeForm  alloc] initWithDictionary:[CZJUtils DataFromJson:json] Type:CZJHomeGetDataFromServerTypeOne];
                }
            }
            else if (dataType == CZJHomeGetDataFromServerTypeTwo)
            {
                //推荐商品分页返回数据
                [_homeForm  appendGoodsRecommendDataWith:[CZJUtils DataFromJson:json]];
            }
        }
        success(json);
    };
    
    __block CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    CZJGeneralBlock loadHomeBlock = ^{
        NSString* explicitUrl = @"";
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        switch (dataType) {
            case CZJHomeGetDataFromServerTypeOne:
            {
                explicitUrl = kCZJServerAPIShowHome;
                [params setValuesForKeysWithDictionary:_params];
            }
                break;
                
            case CZJHomeGetDataFromServerTypeTwo:
            {
                explicitUrl = kCZJServerAPIGetRecoGoods;
                int randNum = [[USER_DEFAULT valueForKey:kUserDefaultRandomCode]intValue];
                [params setValuesForKeysWithDictionary:_params];
                [params setValue:@(page) forKey:@"page"];
                [params setValue:@(randNum) forKey:@"randomCode"];
            }
                break;
            default:
                break;
        }
        
        [CZJNetWorkInstance postJSONWithUrl:explicitUrl
                                 parameters:params
                                    success:successBlock
                                       fail:failBlock];
    };
    [CZJUtils performBlock:loadHomeBlock afterDelay:0];
    
    //定位服务开启与否的各种情况
//    LocationBlock locationHander = ^(CLLocationCoordinate2D locationCorrrdinate){
//        [_params setObject:@(locationCorrrdinate.longitude) forKey:@"lng"];
//        [_params setObject:@(locationCorrrdinate.latitude) forKey:@"lat"];
//        if (CZJHomeGetDataFromServerTypeOne == 0) {
//            [self setCurLocation:locationCorrrdinate];
//        }
//    };
//    if (IS_IOS8)
//    {
//        [[CCLocationManager shareLocation] getLocationCoordinate:locationHander];
//    }
//    else if (IS_IOS7)
//    {
//        [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:locationHander];
//    }
}


#pragma mark- 分类
- (void)showCategoryTypeId:(NSString*)typeId
                   success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValue:typeId forKey:@"typeId"];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetCategoryData
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadGoodsList:(NSDictionary*)postParams
                 type:(CZJHomeGetDataFromServerType)type
              success:(CZJSuccessBlock)success
                 fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_goodsForm)
            {
                [_goodsForm setNewDictionary:dict WithType:type];
            }
            else
            {
                _goodsForm = [[CZJGoodsForm alloc] initWithDictionary:dict WithType:type];
                [_goodsForm setNewDictionary:dict WithType:type];
            }
            
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        failure();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGoodsList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)loadGoodsFilterTypes:(NSDictionary*)postParams
                     success:(CZJSuccessBlock)success
                        fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        failure();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGoodsFilterList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)loadGoodsPriceOrBrandList:(NSDictionary*)postParams
                             type:(NSString*)typeName
                          success:(CZJSuccessBlock)success
                             fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        failure();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    NSString* urlAPI;
    if ([typeName isEqualToString:@"品牌"])
    {
        urlAPI = kCZJServerAPIGoodsBrandsList;
    }
    if ([typeName isEqualToString:@"价格"])
    {
        urlAPI = kCZJServerAPIGoodsPriceList;
    }
    [CZJNetWorkInstance postJSONWithUrl:urlAPI
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


#pragma mark- 筛选列表，汽车车型选择
- (void)getCarBrandsList:(CZJSuccessBlock)success
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_carForm)
            {
                [_carForm setNewCarBrandsFormDictionary:dict];
            }
            else
            {
                _carForm = [[CZJCarForm alloc]initWithDictionary:dict];
                [_carForm setNewCarBrandsFormDictionary:dict];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:@(_curLocation.longitude) forKey:@"lng"];
    [_params setObject:@(_curLocation.latitude) forKey:@"lat"];
    
    [params setValuesForKeysWithDictionary:_params];
    
    if (!_carForm)
    {
        [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadCarBrands
                                 parameters:params
                                    success:successBlock
                                       fail:failBlock];
    }
}

- (void)loadCarSeriesWithBrandId:(NSString*)brandId
                        BrandName:(NSString*)brandName
                          Success:(CZJGeneralBlock)success
                             fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_carForm)
            {
                [_carForm setNewCarSeriesWithDict:dict AndBrandName:brandName];
            }
            else
            {
                _carForm = [[CZJCarForm alloc]initWithDictionary:dict];
                [_carForm setNewCarSeriesWithDict:dict AndBrandName:brandName];
            }
            DLog(@"login suc");
            success();
        }
    };
        
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:brandId forKey:@"brandId"];

    [params setValuesForKeysWithDictionary:_params];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadCarSeries
                            parameters:params
                               success:successBlock
                                  fail:failBlock];
}

- (void)loadCarModelSeriesId:(NSString*)seriesId
                      Success:(CZJGeneralBlock)success
                         fail:(CZJFailureBlock)fail
{
    
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_carForm)
            {
                [_carForm setNewCarModelsWithDict:dict ];
            }
            else
            {
                _carForm = [[CZJCarForm alloc]initWithDictionary:dict];
                [_carForm setNewCarModelsWithDict:dict ];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:seriesId forKey:@"seriesId"];
    
    [params setValuesForKeysWithDictionary:_params];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadCarModels
                            parameters:params
                               success:successBlock
                                  fail:failBlock];
    
}



#pragma mark- 获取商品或服务详情
- (void)loadDetailsWithType:(CZJDetailType)type
            AndStoreItemPid:(NSString*)storeItemPid
                    Success:(CZJGeneralBlock)success
                       fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:storeItemPid forKey:@"storeItemPid"];
    
    [params setValuesForKeysWithDictionary:_params];
    NSString* apiUrl;
    if (CZJDetailTypeGoods == type)
    {
        apiUrl = kCZJServerAPIGoodsDetail;
    }
    else if (CZJDetailTypeService == type)
    {
        apiUrl = kCZJServerAPIServiceDetail;
    }
    
    [CZJNetWorkInstance postJSONWithUrl:apiUrl
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)loadDetailHotRecommendWithType:(CZJDetailType)type
                            andStoreId:(NSString*)storeId
                               Success:(CZJGeneralBlock)success
                                  fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_detailsForm)
            {
//                [_detailsForm setNewRecommendDictionary:dict WithType:type];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:storeId forKey:@"storeId"];
    
    [params setValuesForKeysWithDictionary:_params];
    NSString* apiUrl;
    if (CZJDetailTypeGoods == type)
    {
        apiUrl = kCZJServerAPIGoodsHotReco;
    }
    else if (CZJDetailTypeService == type)
    {
        apiUrl = kCZJServerAPIServiceHotReco;
    }
    
    [CZJNetWorkInstance postJSONWithUrl:apiUrl
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadGoodsSKU:(NSDictionary*)postParams
             Success:(CZJGeneralBlock)success
                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setValuesForKeysWithDictionary:postParams];
    [params setValuesForKeysWithDictionary:_params];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGoodsSKU
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadShoppingCouponsCart:(NSDictionary*)postParams
                        Success:(CZJGeneralBlock)success
                           fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_shoppingCartForm)
            {
                [_shoppingCartForm setNewCouponsDictionary:dict];
            }
            else
            {
                _shoppingCartForm  = [[CZJShoppingCartForm alloc]initWithDictionary:dict];
                [_shoppingCartForm setNewCouponsDictionary:dict];
            }
            
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIStoreCoupons
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)takeCoupons:(NSDictionary*)postParams
            Success:(CZJSuccessBlock)success
               fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPITakeCoupon
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadUserEvalutions:(NSDictionary*)postParams
                      type:(CZJHomeGetDataFromServerType)type
                   SegType:(CZJEvalutionType)segType
                   Success:(CZJGeneralBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_detailsForm)
            {
                if (CZJHomeGetDataFromServerTypeOne == type)
                {
//                    [_detailsForm setEvalutionInfoWithDictionary:dict WitySegType:segType];
                }
                else if ( CZJHomeGetDataFromServerTypeTwo == type)
                {
//                    [_detailsForm appendEvalutionInfoWithDictionary:dict WitySegType:segType];
                }
            }
            else
            {
//                _detailsForm = [[CZJDetailForm alloc] initWithDictionary:dict];
//                [_detailsForm setEvalutionInfoWithDictionary:dict WitySegType:segType];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setValuesForKeysWithDictionary:postParams];
    [params setValuesForKeysWithDictionary:_params];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPICommentsList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)loadUserEvalutionReplys:(NSDictionary*)postParams
                           type:(CZJHomeGetDataFromServerType)type
                        Success:(CZJGeneralBlock)success
                           fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_detailsForm)
            {
                
                if (CZJHomeGetDataFromServerTypeOne == type)
                {
//                    [_detailsForm setEvalutionReplyWithDictionary:dict];
                }
                else if ( CZJHomeGetDataFromServerTypeTwo == type)
                {
//                    [_detailsForm appendEvalutionReplyWithDictionary:dict];
                }
            }
            else
            {
//                _detailsForm = [[CZJDetailForm alloc] initWithDictionary:dict];
//                [_detailsForm setEvalutionReplyWithDictionary:dict];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIReplyList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


#pragma mark- 门店
- (void)showStoreWithParams:(NSDictionary*)postParams
                       type:(CZJHomeGetDataFromServerType)type
                    success:(CZJSuccessBlock)success
                       fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_storeForm)
            {
                if (CZJHomeGetDataFromServerTypeOne == type) {
                    [_storeForm setNewStoreListDataWithDictionary:dict];
                }
                else
                {
                    [_storeForm appendStoreListData:dict];
                }
            }
            else
            {
                _storeForm = [[CZJStoreForm alloc]initWithDictionary:dict];
                [_storeForm setNewStoreListDataWithDictionary:dict];
            }
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        failure();
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [_params setObject:@(_curLocation.longitude) forKey:@"lng"];
    [_params setObject:@(_curLocation.latitude) forKey:@"lat"];
    
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetNearbyStores
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadStoreInfo:(NSDictionary*)postParams
                success:(CZJSuccessBlock)success
                   fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetStoreDetail
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadStoreDetail:(NSDictionary*)postParams
                success:(CZJSuccessBlock)success
                   fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadGoodsInStore
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)attentionStore:(NSDictionary*)postParams
               success:(CZJSuccessBlock)success
{
    [self generalPost:postParams success:success andServerAPI:kCZJServerAPIAttentionStore];
}

- (void)cancleAttentionStore:(NSDictionary*)postParams
               success:(CZJSuccessBlock)success
{
    [self generalPost:postParams success:success andServerAPI:kCZJServerAPICancelAttentionStore];
}

- (void)attentionGoods:(NSDictionary*)postParams
               success:(CZJSuccessBlock)success
{
    [self generalPost:postParams success:success andServerAPI:kCZJServerAPIAttentaionGoods];
}

- (void)cancleAttentionGoods:(NSDictionary*)postParams
               success:(CZJSuccessBlock)success
{
    [self generalPost:postParams success:success andServerAPI:kCZJServerAPICancleAttentionGoods];
}

- (void)loadOtherStoreList:(NSDictionary*)postParams
                   success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadOtherStoreList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}



#pragma mark- 发现
- (void)showDiscoverWithBlocksuccess:(CZJSuccessBlock)success
                                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            [_discoverForms setValuesForKeysWithDictionary:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetDiscovery
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


#pragma mark- 购物车
- (void)loadShoppingCart:(NSDictionary*)postParams
                    type:(CZJHomeGetDataFromServerType)type
                 Success:(CZJGeneralBlock)success
                    fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_shoppingCartForm)
            {
                if (CZJHomeGetDataFromServerTypeOne == type) {
                    [_shoppingCartForm setNewShoppingCartDictionary:dict];
                }
                else if (CZJHomeGetDataFromServerTypeTwo == type)
                {
                    [_shoppingCartForm appendNewShoppingCartData:dict];
                }
                
            }
            else
            {
                _shoppingCartForm = [[CZJShoppingCartForm alloc] initWithDictionary:dict];
                [_shoppingCartForm setNewShoppingCartDictionary:dict];
            }
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:postParams];
    [params setValuesForKeysWithDictionary:_params];
    
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIShoppingCartList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadShoppingCartCount:(NSDictionary*)postParams
                      Success:(CZJGeneralBlock)success
                         fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            if (success)
            {
                success(json);
            }
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIShoppingCartCount
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)addProductToShoppingCart:(NSDictionary*)postParams
                         Success:(CZJGeneralBlock)success
                            fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            [USER_DEFAULT setObject:[dict valueForKey:@"msg"] forKey:kUserDefaultShoppingCartCount];
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIAddToShoppingCart
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)removeProductFromShoppingCart:(NSDictionary*)postParams
                              Success:(CZJGeneralBlock)success
                                 fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIDeleteShoppingCartInfo
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadSettleOrder:(NSDictionary*)postParams
                Success:(CZJSuccessBlock)success
                   fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPISettleOrders
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)submitOrder:(NSDictionary*)postParams
            Success:(CZJSuccessBlock)success
               fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPISubmitOrder
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)loadStoreSetupList:(NSDictionary*)postParams
                   Success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetSetupStoreList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)loadAddrList:(NSDictionary*)postParams
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetAddrList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//添加地址
- (void)addDeliveryAddr:(NSDictionary*)postParams
                Success:(CZJGeneralBlock)success
                   fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIAddAddr
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//修改收货地址
- (void)updateDeliveryAddr:(NSDictionary*)postParams
                   Success:(CZJGeneralBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIUpdateAddr
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//删除收货地址
- (void)removeDeliveryAddr:(NSDictionary*)postParams
                   Success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIRemoveAddr
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//设置默认地址
- (void)setDefaultAddr:(NSDictionary*)postParams
               Success:(CZJSuccessBlock)success
                  fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json)
    {
        if ([self showAlertView:json])
        {
        }
        success(json);
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:_params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPISetDefaultAddr
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}



- (void)generalPost:(NSDictionary*)postParams
            success:(CZJSuccessBlock)success
       andServerAPI:(NSString*)api
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:api
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)getOrderList:(NSDictionary*)postParams
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetOrderList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)getOrderDetail:(NSDictionary*)postParams
               Success:(CZJSuccessBlock)success
                  fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetOrderDetail
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)getOrderCarCheck:(NSDictionary*)postParams
                 Success:(CZJSuccessBlock)success
                    fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPICarCheck
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)getOrderBuildProgress:(NSDictionary*)postParams
                      Success:(CZJSuccessBlock)success
                         fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIBuildingProgress
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


- (void)getReturnedOrderList:(NSDictionary*)postParams
                     Success:(CZJSuccessBlock)success
                        fail:(CZJFailureBlock)fail
{
    
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetReturnedOrderList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}



- (void)getReturnableOrderList:(NSDictionary*)postParams
                       Success:(CZJSuccessBlock)success
                          fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetReturnableOrderList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//获取用户信息详情
- (void)getUserInfo:(NSDictionary*)postParams
            Success:(CZJSuccessBlock)success
               fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            if (!_userInfoForm)
            {
                _userInfoForm = [[UserBaseForm alloc]init];
            }
            [_userInfoForm setUserInfoWithDictionary:[CZJUtils DataFromJson:json]];
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetUserInfo
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//上传用户头像
- (void)uploadUserHeadPic:(NSDictionary*)postParams
                    Image:(UIImage*)image
                  Success:(CZJSuccessBlock)success
                     fail:(CZJFailureBlock)fail
{
    [self generalUploadImage:image withAPI:kCZJServerAPIUploadHeadPic Success:success fail:fail];
}


- (void)generalUploadImage:(UIImage*)image
                   withAPI:(NSString*)serverAPI
                   Success:(CZJSuccessBlock)success
                      fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    
    [CZJNetWorkInstance uploadImageWithUrl:serverAPI
                                     Image:image
                                Parameters:params
                                   success:successBlock
                                   failure:failBlock];
}

//修改用户信息
- (void)updateUserInfo:(NSDictionary*)postParams
               Success:(CZJSuccessBlock)success
                  fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIUpdateUserInfo
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//添加车辆
- (void)addMyCar:(NSDictionary*)postParams
         Success:(CZJSuccessBlock)success
            fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIAddCar
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//获取爱车列表
- (void)getMyCarList:(NSDictionary*)postParams
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetCarlist
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//移除爱车
- (void)removeMyCar:(NSDictionary*)postParams
            Success:(CZJSuccessBlock)success
               fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIRemoveCar
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//设置默认车辆
- (void)setDefaultCar:(NSDictionary*)postParams
              Success:(CZJSuccessBlock)success
                 fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPISetDefaultCar
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


//获取浏览记录
- (void)loadScanList:(NSDictionary*)postParams
             Success:(CZJSuccessBlock)success
                fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIMyScanList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//清空浏览记录
- (void)clearScanList:(NSDictionary*)postParams
              Success:(CZJSuccessBlock)success
                 fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIClearScanList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//搜索
- (void)searchAnything:(NSDictionary*)postParams
               Success:(CZJSuccessBlock)success
                  fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPISearch
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//获取服务分类
- (void)loadServiceType:(NSDictionary*)postParams
                Success:(CZJSuccessBlock)success
                   fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetServiceTypeList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//获取关注列表
- (void)loadMyAttentionList:(NSDictionary*)postParams
                    success:(CZJSuccessBlock)success
                       fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetAttentionList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

//取消关注列表
- (void)cancleAttentionList:(NSDictionary*)postParams
                    Success:(CZJSuccessBlock)success
                       fail:(CZJFailureBlock)fail
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            success(json);
        }
    };
    
    CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValuesForKeysWithDictionary:self.params];
    [params setValuesForKeysWithDictionary:postParams];
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIRemoveAttentions
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


-(NSString*)returnDetailInfoWith:(EWEBTYPE)webType
                          itemId:(NSString*)itemId
                          typeId:(NSString*)typeId
                        moreFlag:(BOOL)moreFlag
                        sortType:(int)sortType
                         success:(void (^)())success
                            fail:(void (^)())fail{
    
    NSString* chezhu_id = [CZJLoginModelInstance cheZhuId];
    NSString* url_type = @"";
    switch (webType) {
        case eActivity:{
            url_type = @"chezhu/showStoreRecommend.do";
            url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&storeId=%@",kCZJServerAddr,url_type,chezhu_id,itemId];
        }
            break;
        case eRecomment:
            url_type = @"chezhu/showStoreRecommend.do";
            url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&recommendId=%@",kCZJServerAddr,url_type,chezhu_id,itemId];
            break;
        case eStoreInfo:{
            url_type = @"chezhu/showStoreInfo.do";
            
            if (typeId) {
                
                if (moreFlag) {
                    url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&storeId=%@&typeId=%@&moreFlag=true&sortType=%d",kCZJServerAddr,url_type,chezhu_id,itemId,typeId,sortType];
                }else{
                    url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&storeId=%@&typeId=%@",kCZJServerAddr,url_type,chezhu_id,itemId,typeId];
                }
                
            }else{
                url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&storeId=%@",kCZJServerAddr,url_type,chezhu_id,itemId];
            }
            
        }
            break;
        case eServiceItem:{
            url_type = @"chezhu/showServiceItem.do";
            url_type = [NSString stringWithFormat:@"%@/%@?chezhuId=%@&itemId=%@",kCZJServerAddr,url_type,chezhu_id,itemId];
        }
            break;
        default:
            break;
    }
    
    success();
    return url_type;
}

@end
