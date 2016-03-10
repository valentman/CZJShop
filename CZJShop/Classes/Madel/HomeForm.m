//
//  HomeForm.m
//  CheZhiJian
//
//  Created by chelifang on 15/7/11.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "HomeForm.h"

@implementation HomeForm
@synthesize activityFroms = _activityFroms;
@synthesize serviceForms = _serviceForms;
@synthesize carInfoForms = _carInfoForms;
@synthesize secSkillForms = _secSkillForms;
@synthesize bannerOneForms = _bannerOneForms;
@synthesize limitBuyForms = _limitBuyForms;
@synthesize brandRecommendForms = _brandRecommendForms;
@synthesize bannerTwoForms = _bannerTwoForms;
@synthesize specialRecommendForms = _specialRecommendForms;
@synthesize goodRecommentForms = _goodRecommentForms;
@synthesize goodRecommendFromGroupedAry = _goodRecommendFromGroupedAry;
@synthesize coupon;
@synthesize serverTime;


//推荐商品分页返回数据
-(void)appendGoodsRecommendDataWith:(NSDictionary*)dictionary{
    if ([dictionary valueForKey:@"msg"]) {
        NSArray* recommends = [dictionary valueForKey:@"msg"];
        _goodRecommentForms = [[GoodsRecommendForm objectArrayWithKeyValuesArray:recommends] mutableCopy];
        float count = (int)_goodRecommentForms.count;
        float count2 = ceilf(count/2);
        [_goodRecommendFromGroupedAry removeAllObjects];
        for (int i  = 0; i < count2; i++)
        {
            NSMutableArray* array = [NSMutableArray array];
            [_goodRecommendFromGroupedAry addObject:array];
        }
        for (int i = 0; i < count; i++) {
            int index = i / 2;
            [_goodRecommendFromGroupedAry[index] addObject:_goodRecommentForms[i]];
        }
    }
}

-(void)setNewDictionary:(NSDictionary*)dictionary{
    [self cleanData];
    NSDictionary* dict = [dictionary valueForKey:@"msg"];
    
    _activityFroms = [[ActivityForm objectArrayWithKeyValuesArray:[dict valueForKey:@"activitys"]] mutableCopy];
    _serviceForms = [[ServiceForm objectArrayWithKeyValuesArray:[dict valueForKey:@"services"]] mutableCopy];
    _carInfoForms = [[CarInfoForm objectArrayWithKeyValuesArray:[dict valueForKey:@"news"]] mutableCopy];
    _secSkillForms = [[SecSkillsForm objectArrayWithKeyValuesArray:[dict valueForKey:@"skills"]] mutableCopy];
    _bannerOneForms = [[BannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners1"]] mutableCopy];
    _limitBuyForms = [[LimitBuyForm objectArrayWithKeyValuesArray:[dict valueForKey:@"limits"]] mutableCopy];
    _brandRecommendForms = [[BrandRecommendForm objectArrayWithKeyValuesArray:[dict valueForKey:@"brands"]] mutableCopy];
    _bannerTwoForms = [[BannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners2"]] mutableCopy];
    _specialRecommendForms = [[SpecialRecommendForm objectArrayWithKeyValuesArray:[dict valueForKey:@"features"]] mutableCopy];
    serverTime = dictionary[@"msg"][@"currentTime"];
}

-(id)initWithDictionary:(NSDictionary*)dictionary Type:(int)type{
    
    if (self = [super init]) {
        
        if (!type) {
            if (_activityFroms) {
                [_activityFroms removeAllObjects];
            }
            else{
                _activityFroms = [NSMutableArray array];
            }
            
            if (_serviceForms) {
                [_serviceForms removeAllObjects];
            }
            else{
                _serviceForms = [NSMutableArray array];
            }
            
            if (_carInfoForms) {
                [_carInfoForms removeAllObjects];
            }
            else{
                _carInfoForms = [NSMutableArray array];
            }
            
            if (_secSkillForms) {
                [_secSkillForms removeAllObjects];
            }
            else{
                _secSkillForms = [NSMutableArray array];
            }
            
            if (_bannerOneForms) {
                [_bannerOneForms removeAllObjects];
            }
            else{
                _bannerOneForms = [NSMutableArray array];
            }
            
            if (_bannerTwoForms) {
                [_bannerTwoForms removeAllObjects];
            }
            else{
                _bannerTwoForms = [NSMutableArray array];
            }
            
            if (_limitBuyForms) {
                [_limitBuyForms removeAllObjects];
            }
            else{
                _limitBuyForms = [NSMutableArray array];
            }
            
            if (_brandRecommendForms) {
                [_brandRecommendForms removeAllObjects];
            }
            else{
                _brandRecommendForms = [NSMutableArray array];
            }
            
            if (_specialRecommendForms) {
                [_specialRecommendForms removeAllObjects];
            }
            else{
                _specialRecommendForms = [NSMutableArray array];
            }
            
            if (_goodRecommentForms) {
                [_goodRecommentForms removeAllObjects];
            }
            else{
                _goodRecommentForms = [NSMutableArray array];
            }
            if (_goodRecommendFromGroupedAry) {
                [_goodRecommendFromGroupedAry removeAllObjects];
            }
            else
            {
                _goodRecommendFromGroupedAry = [NSMutableArray array];
            }
        }
        else
        {
            if (!_activityFroms) {
                _activityFroms = [NSMutableArray array];
            }
            
            if (!_serviceForms) {
                _serviceForms = [NSMutableArray array];
            }
            
            if (!_carInfoForms) {
                _carInfoForms = [NSMutableArray array];
            }
            
            if (!_secSkillForms) {
                _secSkillForms = [NSMutableArray array];
            }
            
            if (!_bannerOneForms) {
                _bannerOneForms = [NSMutableArray array];
            }
            
            if (!_bannerTwoForms) {
                _bannerTwoForms = [NSMutableArray array];
            }
            
            if (!_limitBuyForms) {
                _limitBuyForms = [NSMutableArray array];
            }
            
            if (!_brandRecommendForms) {
                _brandRecommendForms = [NSMutableArray array];
            }
            
            if (!_specialRecommendForms) {
                _specialRecommendForms = [NSMutableArray array];
            }
            
            if (!_goodRecommentForms) {
                _goodRecommentForms = [NSMutableArray array];
            }
            if (!_goodRecommendFromGroupedAry) {
                _goodRecommendFromGroupedAry = [NSMutableArray array];
            }
        }

        [self setNewDictionary:dictionary];
        return self;
    }
    return self;
}

-(void)cleanData{
    [_activityFroms removeAllObjects];
    [_serviceForms removeAllObjects];
    [_carInfoForms removeAllObjects];
    [_secSkillForms removeAllObjects];
    [_bannerOneForms removeAllObjects];
    [_limitBuyForms removeAllObjects];
    [_brandRecommendForms removeAllObjects];
    [_bannerTwoForms removeAllObjects];
    [_specialRecommendForms removeAllObjects];
    [_goodRecommentForms removeAllObjects];
    [_goodRecommendFromGroupedAry removeAllObjects];
}
@end

//----------------------活动----------------------
@implementation ActivityForm
@end

//---------------------服务列表---------------------
@implementation ServiceForm
@end

//---------------------汽车资讯----------------------
@implementation CarInfoForm : NSObject
@end

//-----------------------秒杀----------------------
@implementation SecSkillsForm : NSObject
@end

@implementation CZJMiaoShaTimesForm
@end

@implementation CZJMiaoShaControllerForm
+ (NSDictionary *)objectClassInArray{
    return @{
             @"skillTimes" : @"CZJMiaoShaTimesForm",
             };
}
@end

@implementation CZJMiaoShaCellForm
@end

//---------------------广告栏一---------------------
@implementation BannerForm : NSObject
@end

//---------------------限量抢购---------------------
@implementation LimitBuyForm : NSObject
@end

//---------------------品牌推荐---------------------
@implementation BrandRecommendForm : NSObject
@end

//---------------------特色推荐---------------------
@implementation SpecialRecommendForm : NSObject
@end

//---------------------推荐商品---------------------
@implementation GoodsRecommendForm
@end