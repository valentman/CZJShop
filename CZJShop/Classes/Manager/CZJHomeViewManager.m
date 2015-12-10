  //
//  CZJHomeViewManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJHomeViewManager.h"
#import "CZJNetworkManager.h"
#import "WGS84TOGCJ02.h"
#import "CZJLoginModelManager.h"
#import "CZJErrorCodeManager.h"
#import "CCLocationManager.h"
#import "ZXLocationManager.h"
#import "HomeForm.h"
#import "CZJStoreForm.h"
#import "CZJCarForm.h"

@implementation CZJHomeViewManager
#pragma mark- synthesize
@synthesize curLocation =  _curLocation;
@synthesize homeForm = _homeForm;
@synthesize storeForm = _storeForm;
@synthesize params = _params;
@synthesize discoverForms = _discoverForms;



#pragma mark- implement
singleton_implementation(CZJHomeViewManager);

- (id) init
{
    if (self = [super init])
    {
        _params = [NSMutableDictionary alloc];
        _discoverForms = [NSMutableDictionary dictionary];
        NSDictionary* _tmpparams = @{@"chezhuId" : nil == [CZJLoginModelInstance cheZhuId] ? @"0" : [CZJLoginModelInstance cheZhuId],
                                     @"cityId" : nil == [CZJLoginModelInstance cityId] ? @"0" : [CZJLoginModelInstance cityId],
                                     @"lng" : @(_curLocation.longitude),
                                     @"lat" : @(_curLocation.latitude),
                                     @"os" : @"ios",
                                     @"suffix" : ((iPhone6Plus || iPhone6) ? @"@3x" : @"@2x")
                                     };
        _params = [_tmpparams mutableCopy];
        
        //此处只在第一次进入程序或启动时间超过一天才更新地区信息
        UInt64 currentTime = [[NSDate date] timeIntervalSince1970];     //当前时间
        UInt64 lastUpdateTime = [[USER_DEFAULT valueForKey:kUserDefaultTime] longLongValue];   //上次更新时间
        UInt64 intervalTime = currentTime - lastUpdateTime;
        if (0 == currentTime ||
            intervalTime > 86400)
        {
            [USER_DEFAULT setValue:[NSString stringWithFormat:@"%llu",currentTime] forKey:kUserDefaultTime];
            [self getAreaInfos];
        }
        
        
        if ([CZJUtils isTimeCrossOneDay])
        {
            [self getAreaInfos];
        }
        else
        {
            [self getAreaInfos];
        }
        return self;
    }
    return nil;
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
            NSDictionary* newdict = [CZJUtils DataFromJson:json];
            [CZJUtils writeDataToPlist:[newdict mutableCopy] withPlistName:kCZJPlistFileCitys];
            NSMutableDictionary* newdicts = [CZJUtils readDataFromPlistWithName:kCZJPlistFileCitys];
            DLog(@"%@", [newdicts description]);
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
                //加载更多，追加数据
                [_homeForm  appendGoodsRecommendDataWith:[CZJUtils DataFromJson:json]];
            }
        }
        success(json);
    };
    
    __block CZJFailureBlock failBlock = ^(){
        [[CZJErrorCodeManager sharedCZJErrorCodeManager] ShowNetError];
        fail();
    };
    
    LocationBlock locationHander = ^(CLLocationCoordinate2D locationCorrrdinate){
        [_params setObject:@(locationCorrrdinate.longitude) forKey:@"lng"];
        [_params setObject:@(locationCorrrdinate.latitude) forKey:@"lat"];
        if (CZJHomeGetDataFromServerTypeOne == 0) {
            [self setCurLocation:locationCorrrdinate];
        }
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
                [params setValuesForKeysWithDictionary:_params];
                [params setValue:@(page) forKey:@"page"];
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
    //定位服务开启与否的各种情况
    BOOL isFlag = YES;
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        isFlag= NO;
    }
    if (isFlag)
    {
        _curLocation.latitude = 0;
        _curLocation.longitude = 0;
    }
    else if (IS_IOS8)
    {
        [[CCLocationManager shareLocation] getLocationCoordinate:locationHander];
    }
    else if (IS_IOS7)
    {
        [[ZXLocationManager sharedZXLocationManager] getLocationCoordinate:locationHander];
    }
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


#pragma mark- 发现
- (void)showDiscoverWithBlocksuccess:(CZJSuccessBlock)success fail:(CZJFailureBlock)fail
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


#pragma mark- 服务列表
- (void)showSeverciceList:(NSDictionary*)postParams
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
                    [_storeForm setNewStoreServiceListDataWithDictionary:dict];
                }
                else
                {
                    [_storeForm appendStoreServiceListData:dict];
                }
            }
            else
            {
                _storeForm = [[CZJStoreForm alloc]initWithDictionary:dict];
                [_storeForm setNewStoreServiceListDataWithDictionary:dict];
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
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPIGetServiceList
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}

- (void)getCarBrandsList:(CZJSuccessBlock)success
                    fail:(CZJFailureBlock)failure
{
    CZJSuccessBlock successBlock = ^(id json){
        if ([self showAlertView:json])
        {
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if (_carForm)
            {
                [_carForm setNewDictionary:dict];
            }
            else
            {
                _carForm = [[CZJCarForm alloc]initWithDictionary:dict];
                [_storeForm setNewStoreServiceListDataWithDictionary:dict];
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
    
    [CZJNetWorkInstance postJSONWithUrl:kCZJServerAPILoadCarBrands
                             parameters:params
                                success:successBlock
                                   fail:failBlock];
}


-(void)getSomeInfoSuccess:(CZJSuccessBlock)success{
    NSString* tst = [[CZJLoginModelInstance  cheZhuId] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString* str = [NSString stringWithFormat:@"{\"chezhuId\":\"%@\",\"cityId\":\"%@\",\"mobile\":\"%@\",\"lat\":\"%@\",\"lng\":\"%@\"}",tst,[CZJLoginModelInstance cityId],[CZJLoginModelInstance mobile],[NSNumber numberWithDouble:_curLocation.latitude],[NSNumber numberWithDouble:_curLocation.longitude]];
    success(str);
}

@end
