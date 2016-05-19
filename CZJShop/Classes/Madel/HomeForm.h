//
//  HomeForm.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/11.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

/******************************-首页数据---****************************/
@interface HomeForm : NSObject{
    NSMutableArray* _activityFroms;
    NSMutableArray* _serviceForms;
    NSMutableArray* _carInfoForms;
    NSMutableArray* _secSkillForms;
    NSMutableArray* _skillTimes;
    NSMutableArray* _bannerOneForms;
    NSMutableArray* _limitBuyForms;
    NSMutableArray* _brandRecommendForms;
    NSMutableArray* _bannerTwoForms;
    NSMutableArray* _specialRecommendForms;
    NSMutableArray* _goodRecommentForms;
    NSMutableArray* _goodRecommendFromGroupedAry;
}
@property(nonatomic,strong) NSMutableArray* activityFroms;
@property(nonatomic,strong) NSMutableArray* serviceForms;
@property(nonatomic,strong) NSMutableArray* carInfoForms;
@property(nonatomic,strong) NSMutableArray* secSkillForms;
@property(nonatomic,strong) NSMutableArray* skillTimes;
@property(nonatomic,strong) NSMutableArray* bannerOneForms;
@property(nonatomic,strong) NSMutableArray* limitBuyForms;
@property(nonatomic,strong) NSMutableArray* brandRecommendForms;
@property(nonatomic,strong) NSMutableArray* bannerTwoForms;
@property(nonatomic,strong) NSMutableArray* specialRecommendForms;
@property(nonatomic,strong) NSMutableArray* goodRecommentForms;
@property(nonatomic,strong) NSMutableArray* goodRecommendFromGroupedAry;
@property(nonatomic,strong) NSString* coupon;
@property(nonatomic, strong) NSString* serverTime;

-(id)init;
-(void)appendGoodsRecommendDataWith:(NSDictionary*)dictionary;
-(void)setNewDictionary:(NSDictionary*)dictionary;
-(void)cleanData;
@end


//-----------------------首页活动-----------------------
@interface ActivityForm : NSObject
@property(nonatomic, strong) NSString* activityId;
@property(nonatomic, strong) NSString* img;
@property(nonatomic, strong) NSString* url;
@end

//-----------------------首页服务-----------------------
@interface ServiceForm : NSObject
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* img;
@property(nonatomic, strong) NSString* typeId;
@property(nonatomic, strong) NSString* type;
@property(nonatomic, assign) BOOL need;
@property(nonatomic, assign) BOOL open;
@end

//---------------------首页汽车资讯----------------------
@interface CarInfoForm : NSObject
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* type;
@property(nonatomic, strong) NSString* url;
@end

//-----------------------首页秒杀----------------------
@interface SecSkillsForm : NSObject
@property(nonatomic, strong)NSString* originalPrice;
@property(nonatomic, strong)NSString* storeItemPid;
@property(nonatomic, strong)NSString* itemType;
@property(nonatomic, strong)NSString* itemImg;
@property(nonatomic, strong)NSString* currentPrice;
@end

@interface CZJMiaoShaTimesForm : NSObject
@property (strong, nonatomic) NSString* skillId;
@property (strong, nonatomic) NSString* skillTime;
@property (strong, nonatomic) NSString* status;
@end

@interface CZJMiaoShaControllerForm : NSObject
@property (strong, nonatomic) NSString*  currentTime;
@property (strong, nonatomic) NSArray*  skillTimes;
@end

@interface CZJMiaoShaCellForm : NSObject
@property (strong, nonatomic) NSString* currentPrice;
@property (strong, nonatomic) NSString* homeFlag;
@property (strong, nonatomic) NSString* itemImg;
@property (strong, nonatomic) NSString* itemName;
@property (strong, nonatomic) NSString* itemType;
@property (strong, nonatomic) NSString* limitCount;
@property (strong, nonatomic) NSString* limitPoint;
@property (strong, nonatomic) NSString* originalPrice;
@property (strong, nonatomic) NSString* storeItemPid;
@end

//---------------------首页广告栏一---------------------
@interface BannerForm : NSObject
@property(nonatomic, strong)NSString* img;
@property(nonatomic, strong)NSString* url;
@end

//---------------------首页限量抢购---------------------
@interface LimitBuyForm : NSObject
@property(nonatomic, strong)NSString* originalPrice;
@property(nonatomic, strong)NSString* storeItemPid;
@property(nonatomic, strong)NSString* itemType;
@property(nonatomic, strong)NSString* img;
@property(nonatomic, strong)NSString* currentPrice;
@end

//---------------------首页品牌推荐---------------------
@interface BrandRecommendForm : NSObject
@property(nonatomic, strong)NSString* img;
@property(nonatomic, strong)NSString* url;
@end

//---------------------首页特色推荐---------------------
@interface SpecialRecommendForm : NSObject
@property(nonatomic, strong)NSString* img;
@property(nonatomic, strong)NSString* url;
@end

//---------------------首页推荐商品---------------------
@interface GoodsRecommendForm : NSObject
@property(nonatomic, strong) NSString* storeItemPid;
@property(nonatomic, strong) NSString* itemType;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, strong) NSString* itemImg;
@property(nonatomic, strong) NSString* currentPrice;
@property(nonatomic, strong) NSString* originalPrice;
@end