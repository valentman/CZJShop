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
@synthesize skillTimes = _skillTimes;
@synthesize bannerOneForms = _bannerOneForms;
@synthesize limitBuyForms = _limitBuyForms;
@synthesize brandRecommendForms = _brandRecommendForms;
@synthesize bannerTwoForms = _bannerTwoForms;
@synthesize specialRecommendForms = _specialRecommendForms;
@synthesize goodRecommentForms = _goodRecommentForms;
@synthesize goodRecommendFromGroupedAry = _goodRecommendFromGroupedAry;
@synthesize coupon;
@synthesize serverTime;


-(id)init{
    if (self = [super init])
    {
        _activityFroms = [NSMutableArray array];
        _serviceForms = [NSMutableArray array];
        _carInfoForms = [NSMutableArray array];
        _secSkillForms = [NSMutableArray array];
        _bannerOneForms = [NSMutableArray array];
        _bannerTwoForms = [NSMutableArray array];
        _limitBuyForms = [NSMutableArray array];
        _brandRecommendForms = [NSMutableArray array];
        _specialRecommendForms = [NSMutableArray array];
        _goodRecommentForms = [NSMutableArray array];
        _goodRecommendFromGroupedAry = [NSMutableArray array];
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

-(void)setNewDictionary:(NSDictionary*)dictionary{
    [self cleanData];
    NSDictionary* dict = [dictionary valueForKey:@"msg"];
    
    _activityFroms = [[ActivityForm objectArrayWithKeyValuesArray:[dict valueForKey:@"activitys"]] mutableCopy];
    _serviceForms = [[ServiceForm objectArrayWithKeyValuesArray:[dict valueForKey:@"services"]] mutableCopy];
    _carInfoForms = [[CarInfoForm objectArrayWithKeyValuesArray:[dict valueForKey:@"news"]] mutableCopy];
    _secSkillForms = [[SecSkillsForm objectArrayWithKeyValuesArray:[dict valueForKey:@"skills"]] mutableCopy];
    _skillTimes = [[CZJMiaoShaTimesForm objectArrayWithKeyValuesArray:[dict valueForKey:@"skillTimes"]] mutableCopy];
    _bannerOneForms = [[BannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners1"]] mutableCopy];
    _limitBuyForms = [[LimitBuyForm objectArrayWithKeyValuesArray:[dict valueForKey:@"limits"]] mutableCopy];
    _brandRecommendForms = [[BrandRecommendForm objectArrayWithKeyValuesArray:[dict valueForKey:@"brands"]] mutableCopy];
    _bannerTwoForms = [[BannerForm objectArrayWithKeyValuesArray:[dict valueForKey:@"banners2"]] mutableCopy];
    _specialRecommendForms = [[SpecialRecommendForm objectArrayWithKeyValuesArray:[dict valueForKey:@"features"]] mutableCopy];
    serverTime = dictionary[@"msg"][@"currentTime"];
}


//推荐商品分页返回数据
-(void)appendGoodsRecommendDataWith:(NSDictionary*)dictionary
{
    if ([dictionary valueForKey:@"msg"]) {
        NSArray* recommends = [dictionary valueForKey:@"msg"];
        _goodRecommentForms = [[GoodsRecommendForm objectArrayWithKeyValuesArray:recommends] mutableCopy];
        [_goodRecommendFromGroupedAry addObjectsFromArray:[CZJUtils getAggregationArrayFromArray:_goodRecommentForms]];
    }
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