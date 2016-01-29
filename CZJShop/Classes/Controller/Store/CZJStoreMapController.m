//
//  CZJStoreMapController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/2/15.
//  Copyright © 2015 JoeP. All rights reserved.
//


#import "CZJStoreMapController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "CZJCustomAnnotationView.h"

#import "CZJMAAroundAnnotation.h"
#import "CZJStoreMAAroundForm.h"

#import "CZJBaseDataManager.h"
#import "CZJStoreForm.h"
#import "ZXLocationManager.h"

#import "CZJServiceListController.h"

#define kDefaultCalloutViewMargin       -8
#define MAPKEY @"dd2b9e1576489ef636cdda90c74cbdbe"

@interface CZJStoreMapController ()
<MAMapViewDelegate,
UIGestureRecognizerDelegate,
AMapSearchDelegate>
{
    MAMapView *_mapView;
    UIButton *_locationBtn;//定位按钮
    
    //地址转码
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    
    //附近搜索数据
    NSMutableArray *_pois;
    NSMutableArray *_annotations;
    
    NSString* _curItemId;
    BOOL _isJumped;
}
@end

@implementation CZJStoreMapController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    _isJumped = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToOther:) name:kCZJMaptoStoreWeb object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getAroundMerchantData];
    });
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMapView];
    [self setNav];
    [self initControls];
    [self initSearch];
    [self initAttributes];//初始化数据
}

- (void)jumpToOther:(id)info{
    if (!_isJumped) {
        _isJumped = YES;
        _curItemId = [info object];
    //    [self performSegueWithIdentifier:@"mapToWebViewSID" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNav{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 40, 44, 44);
    [backBtn addTarget:self action:@selector(OnBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"prodetail_btn_back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
}

-(void)initMapView{
    [MAMapServices sharedServices].apiKey = MAPKEY;
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.compassOrigin = CGPointMake(_mapView.compassOrigin.x, 22);
    _mapView.scaleOrigin = CGPointMake(_mapView.scaleOrigin.x, 22);
    [self.view addSubview:_mapView];
    
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = 1;
}

-(void)initControls{
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _locationBtn.frame = CGRectMake(20, CGRectGetHeight(_mapView.bounds)-100, 40, 40);
    _locationBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;//
    _locationBtn.backgroundColor = [UIColor whiteColor];
    _locationBtn.layer.cornerRadius = 5;
    [_locationBtn setImage:[UIImage imageNamed:@"wl_map_icon_position"] forState:UIControlStateNormal];
    [_locationBtn addTarget:self action:@selector(locateAction) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_locationBtn];
    
}

-(void)initSearch{
    _search = [[AMapSearchAPI alloc] initWithSearchKey:MAPKEY Delegate:self];
}

- (void)initAttributes
{
    _annotations = [NSMutableArray array];
    _pois = [NSMutableArray array];
}

//获取附近商家列表
-(void)getAroundMerchantData
{
        NSMutableArray* dataArray = [CZJBaseDataInstance storeForm].storeListForms;
        if (dataArray.count > 0)
        {
            [_mapView removeAnnotations:_annotations];
            [_annotations removeAllObjects];
            CLLocationCoordinate2D location = [CZJBaseDataInstance curLocation];
            for (int i = 0; i < dataArray.count; i++)
            {
                CZJNearbyStoreForm* model = dataArray[i];
                CZJMAAroundAnnotation *annotation = [[CZJMAAroundAnnotation alloc] init];
                annotation.jzmaaroundM = model;
                annotation.title = model.name;
                annotation.subtitle = model.addr;
                annotation.thrtitle = model.openingHours;
                annotation.coordinate = CLLocationCoordinate2DMake([[model lat] doubleValue], [[model lng] doubleValue]);
                [_annotations addObject:annotation];
            }
            
            if (([dataArray count] > 0) && (location.longitude == 0) && (location.latitude == 0))
            {
                _mapView.centerCoordinate = CLLocationCoordinate2DMake([[[dataArray firstObject] lat] doubleValue], [[[dataArray firstObject] lng] doubleValue]);
            }
            
            [self performSelectorOnMainThread:@selector(updateUI)withObject:_annotations waitUntilDone:YES];
        }
}

-(void)updateUI{
    NSLog(@"个数:%ld",(unsigned long)_annotations.count);
    
    
    for (int i = 0; i < _annotations.count; i++) {
        [_mapView addAnnotation:_annotations[i]];
    }
}



//相应事件
-(void)OnBackBtn:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)locateAction{
    if (_mapView.userTrackingMode != MAUserTrackingModeFollow) {
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
}





//逆地理编码
//发起搜索请求
-(void)reGeoAction{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
    }
}

//
-(void)searchAction{
    if (_currentLocation == nil || _search == nil) {
        NSLog(@"search failed");
        return;
    }
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    request.searchType = AMapSearchType_PlaceAround;//附近搜索
    request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    request.keywords = @"餐饮";
    [_search AMapPlaceSearch:request];
}


#pragma mark - MAMapViewDelegate
//更新位置
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    //    NSLog(@"userLocation:%@",userLocation.location);
    _currentLocation = [userLocation.location copy];
}

//替换定位图标
-(void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    if (mode == MAUserTrackingModeNone) {
        [_locationBtn setImage:[UIImage imageNamed:@"wl_map_icon_position"] forState:UIControlStateNormal];
    }else{
        [_locationBtn setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }
}

//点击大头针时
-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self reGeoAction];
    }
    
    
    // 调整自定义callout的位置，使其可以完全显示
    if ([view isKindOfClass:[CZJCustomAnnotationView class]]) {
        CZJCustomAnnotationView *cusView = (CZJCustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:_mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin));
        
        if (!CGRectContainsRect(_mapView.frame, frame))
        {
            CGSize offset = [self offsetToContainRect:frame inRect:_mapView.frame];
            
            CGPoint theCenter = _mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [_mapView convertPoint:theCenter toCoordinateFromView:_mapView];
            
            [_mapView setCenterCoordinate:coordinate animated:YES];
        }
        
    }
    
}

//显示地图标示view  大头针
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CZJCustomAnnotationView *annotationView = (CZJCustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CZJCustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        if ([annotation isKindOfClass:[CZJMAAroundAnnotation class]]){
            annotationView.jzAnnotation = (CZJMAAroundAnnotation *)annotation;
        }
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"map_icon_shop"];
        // 设置中⼼心点偏移,使得标注底部中间点成为经纬度对应点
        //        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}


#pragma mark - AMapSearchDelegate
//搜索失败
-(void)searchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"request :%@,error :%@",request,error);
}

//逆地址编码
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSLog(@"response:%@",response);
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0) {
        title = response.regeocode.addressComponent.province;
    }
    _mapView.userLocation.title = title;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
}

//地址搜索回调
-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response{
    NSLog(@"地址搜索 requset:%@",request);
    
    //清空
    [_mapView removeAnnotations:_annotations];
    [_annotations removeAllObjects];
    [_pois removeAllObjects];
    
    //
    if (response.pois.count > 0) {
        _pois = [[NSMutableArray alloc] initWithArray:response.pois];
        for (int i = 0; i < _pois.count; i++) {
            //标注
            AMapPOI *poi = _pois[i];
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            annotation.title = poi.name;
            annotation.subtitle = poi.address;
            
            [_annotations addObject:annotation];
            
            [_mapView addAnnotation:annotation];
        }
    }
}





#pragma mark - Helpers

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"mapToWebViewSID"]) {
//        CZJServiceDetailInfo* ctr = segue.destinationViewController;
//        ctr.itemId  = _curItemId;
//        ctr.curType = eStoreInfo;
//        ctr.navTitleName = @"门店详情";
    }
}
@end

