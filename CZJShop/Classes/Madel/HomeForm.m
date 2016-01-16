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


-(void)appendGoodsRecommendDataWith:(NSDictionary*)dictionary{
    if ([dictionary valueForKey:@"msg"]) {
        NSArray* recommends = [dictionary valueForKey:@"msg"];
        for (id obj in recommends) {
            GoodsRecommendForm* tmp_ser = [[GoodsRecommendForm alloc] initWithDictionary:obj];
            [_goodRecommentForms addObject:tmp_ser];
        }
        int count = (int)_goodRecommentForms.count;
        int count2 = count/2;
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
    
    NSArray* activitys = [[dictionary valueForKey:@"msg"] valueForKey:@"activitys"];
    for (id obj in activitys) {
        ActivityForm* tmp_ser = [[ActivityForm alloc] initWithDictionary:obj];
        [_activityFroms addObject:tmp_ser];
    }
    
    NSArray* services = [[dictionary valueForKey:@"msg"] valueForKey:@"services"];
    for (id obj in services) {
        ServiceForm* tmp_ser = [[ServiceForm alloc] initWithDictionary:obj];
        [_serviceForms addObject:tmp_ser];
    }
   
    NSArray* carInfos = [[dictionary valueForKey:@"msg"] valueForKey:@"news"];
    for (id obj in carInfos) {
        CarInfoForm* tmp_ser = [[CarInfoForm alloc] initWithDictionary:obj];
        [_carInfoForms addObject:tmp_ser];
    }

    NSArray* secSkills = [[dictionary valueForKey:@"msg"] valueForKey:@"skills"];
    for (id obj in secSkills) {
        SecSkillsForm* tmp_ser = [[SecSkillsForm alloc] initWithDictionary:obj];
        [_secSkillForms addObject:tmp_ser];
    }
    
    NSArray* banerOnes = [[dictionary valueForKey:@"msg"] valueForKey:@"banners1"];
    for (id obj in banerOnes) {
        BannerForm* tmp_ser = [[BannerForm alloc] initWithDictionary:obj];
        [_bannerOneForms addObject:tmp_ser];
    }
    
    NSArray* limits = [[dictionary valueForKey:@"msg"] valueForKey:@"limits"];
    for (id obj in limits) {
        LimitBuyForm* tmp_ser = [[LimitBuyForm alloc] initWithDictionary:obj];
        [_limitBuyForms addObject:tmp_ser];
    }
    
    NSArray* brands = [[dictionary valueForKey:@"msg"] valueForKey:@"brands"];
    for (id obj in brands) {
        BrandRecommendForm* tmp_ser = [[BrandRecommendForm alloc] initWithDictionary:obj];
        [_brandRecommendForms addObject:tmp_ser];
    }
    NSArray* bannerTwos = [[dictionary valueForKey:@"msg"] valueForKey:@"banners2"];
    for (id obj in bannerTwos) {
        BannerForm* tmp_ser = [[BannerForm alloc] initWithDictionary:obj];
        [_bannerTwoForms addObject:tmp_ser];
    }
    
    NSArray* specialRecomsends = [[dictionary valueForKey:@"msg"] valueForKey:@"features"];
    for (id obj in specialRecomsends) {
        SpecialRecommendForm* tmp_ser = [[SpecialRecommendForm alloc] initWithDictionary:obj];
        [_specialRecommendForms addObject:tmp_ser];
    }
    
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
@synthesize activityId;
@synthesize img;
@synthesize url;
-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.activityId = [dictionary valueForKey:@"activityId"];
        self.img = [dictionary valueForKey:@"img"];
        self.url = [dictionary valueForKey:@"url"];
        return self;
    }
    return nil;
}
@end

//---------------------服务列表---------------------
@implementation ServiceForm
@synthesize name;
@synthesize img;
@synthesize typeId;

-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.name = [dictionary valueForKey:@"name"];
        self.img = [dictionary valueForKey:@"img"];
        self.typeId = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"typeId"]];
        self.need = [[dictionary valueForKey:@"need"] boolValue];
        self.open = [[dictionary valueForKey:@"open"] boolValue];
        return self;
    }
    return nil;
}

@end

//---------------------汽车资讯----------------------
@implementation CarInfoForm : NSObject
@synthesize title;
@synthesize type;
@synthesize url;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.title = [dict valueForKey:@"title"];
        self.type = [dict valueForKey:@"type"];
        self.url = [dict valueForKey:@"url"];
        return self;
    }
    return nil;
}
@end

//-----------------------秒杀----------------------
@implementation SecSkillsForm : NSObject
@synthesize originalPrice;
@synthesize storeItemPid;
@synthesize itemType;
@synthesize img;
@synthesize currentPrice;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.originalPrice = [dict valueForKey:@"originalPrice"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.img = [dict valueForKey:@"img"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        return self;
    }
    return nil;
}
@end

//---------------------广告栏一---------------------
@implementation BannerForm : NSObject
@synthesize img;
@synthesize url;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.img = [dict valueForKey:@"img"];
        self.url = [dict valueForKey:@"url"];
        return self;
    }
    return nil;
}
@end

//---------------------限量抢购---------------------
@implementation LimitBuyForm : NSObject
@synthesize originalPrice;
@synthesize storeItemPid;
@synthesize itemType;
@synthesize img;
@synthesize currentPrice;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.originalPrice = [dict valueForKey:@"originalPrice"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.img = [dict valueForKey:@"img"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        return self;
    }
    return nil;
}
@end

//---------------------品牌推荐---------------------
@implementation BrandRecommendForm : NSObject
@synthesize img;
@synthesize url;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.img = [dict valueForKey:@"img"];
        self.url = [dict valueForKey:@"url"];
        return self;
    }
    return nil;
}
@end

//---------------------特色推荐---------------------
@implementation SpecialRecommendForm : NSObject
@synthesize img;
@synthesize url;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.img = [dict valueForKey:@"img"];
        self.url = [dict valueForKey:@"url"];
        return self;
    }
    return nil;
}
@end

//---------------------推荐商品---------------------
@implementation GoodsRecommendForm
-(id)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        self.storeItemPid = [dictionary valueForKey:@"storeItemPid"];
        self.itemType = [dictionary valueForKey:@"itemType"];
        self.itemName = [dictionary valueForKey:@"itemName"];
        self.itemImg = [dictionary valueForKey:@"itemImg"];
        self.currentPrice = [dictionary valueForKey:@"currentPrice"];
        self.originalPrice = [dictionary valueForKey:@"originalPrice"];
        return self;
    }
    return nil;
}
@end








