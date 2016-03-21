//
//  CZJStoreServiceDetailForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailForm.h"
#import "CZJStoreForm.h"

@implementation CZJDetailForm
//@synthesize serviceDetail = _serviceDetail;
//@synthesize storeInfo = _storeInfo;
//@synthesize evalutionInfo = _evalutionInfo;
//@synthesize couponForms = _couponForms;
//@synthesize recommendServiceForms = _recommendServiceForms;
//@synthesize purchaseCount = _purchaseCount;
//@synthesize userEvalutionAllForms = _userEvalutionAllForms;
//@synthesize userEvalutionBadForms = _userEvalutionBadForms;
//@synthesize userEvalutionGoodForms = _userEvalutionGoodForms;
//@synthesize userEvalutionMiddleForms = _userEvalutionMiddleForms;
//@synthesize userEvalutionWithPicForms = _userEvalutionWithPicForms;
//@synthesize userEvalutionReplyForms = _userEvalutionReplyForms;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        if (!_couponForms) {
//            _couponForms = [NSMutableArray array];
//        }
//        if (!_recommendServiceForms) {
//            _recommendServiceForms = [NSMutableArray array];
//        }
//        if (!_userEvalutionAllForms)
//        {
//            _userEvalutionAllForms = [NSMutableArray array];
//        }
//        if (!_userEvalutionWithPicForms)
//        {
//            _userEvalutionWithPicForms = [NSMutableArray array];
//        }
//        if (!_userEvalutionGoodForms)
//        {
//            _userEvalutionGoodForms = [NSMutableArray array];
//        }
//        if (!_userEvalutionMiddleForms)
//        {
//            _userEvalutionMiddleForms = [NSMutableArray array];
//        }
//        if (!_userEvalutionBadForms)
//        {
//            _userEvalutionBadForms = [NSMutableArray array];	
//        }
//        if (!_userEvalutionReplyForms)
//        {
//            _userEvalutionReplyForms = [NSMutableArray array];
//        }
//        return self;
//    }
//    return nil;
//}
//
//- (void)setNewDictionary:(NSDictionary*)dict WithType:(CZJDetailType)type
//{
//    [self resetData];
//    if (CZJDetailTypeService == type)
//    {//服务详情页面
//        _purchaseCount = [dict valueForKey:@"purchaseCount"];
//    }
////    _goodsDetail = [[CZJGoodsDetail alloc]initWithDictionary:[[dict valueForKey:@"msg"] valueForKey:@"goods"]];
//    
//    //门店信息
//    _storeInfo = [[CZJStoreInfoForm alloc]initWithDictionary:[[dict valueForKey:@"msg"] valueForKey:@"store"]];
//    
//    //当前商品或服务评价简介
//    _evalutionInfo = [[CZJDetailEvalInfo alloc]initWithDictionary:[[dict valueForKey:@"msg"] valueForKey:@"evals"]];
//    
//
//    //券信息
//    NSArray* couponArys = [[dict valueForKey:@"msg"] valueForKey:@"coupons"];
//    for (NSDictionary* dict in couponArys)
//    {
//        CZJCouponForm* form = [[CZJCouponForm alloc]initWithDictionary:dict];
//        [_couponForms addObject:form];
//    }
//}
//
//
//- (void)setNewRecommendDictionary:(NSDictionary*)dict WithType:(CZJDetailType)type
//{
//    [_recommendServiceForms removeAllObjects];
//    //当前商品或服务相关推荐
//    NSArray* recoArys = [dict valueForKey:@"msg"];
//    for (NSDictionary* dict in recoArys)
//    {
//        CZJStoreServiceForm* form = [[CZJStoreServiceForm alloc]initWithDictionary:dict];
//        [_recommendServiceForms addObject:form];
//    }
//}
//
//
//- (void)setEvalutionInfoWithDictionary:(NSDictionary*)dict WitySegType:(CZJEvalutionType)type
//{
//    switch (type)
//    {
//        case CZJEvalutionTypeAll:
//            [_userEvalutionAllForms removeAllObjects];
//            break;
//        case CZJEvalutionTypePic:
//            [_userEvalutionWithPicForms removeAllObjects];
//            break;
//        case CZJEvalutionTypeGood:
//            [_userEvalutionGoodForms removeAllObjects];
//            break;
//        case CZJEvalutionTypeMiddle:
//            [_userEvalutionMiddleForms removeAllObjects];
//            break;
//        case CZJEvalutionTypeBad:
//            [_userEvalutionBadForms removeAllObjects];
//            break;
//            
//        default:
//            break;
//    }
//    [self appendEvalutionInfoWithDictionary:dict WitySegType:type];
//}
//
//- (void)appendEvalutionInfoWithDictionary:(NSDictionary*)dict WitySegType:(CZJEvalutionType)type
//{
//    NSArray* couponArys = [dict valueForKey:@"msg"];
//    for (NSDictionary* dict in couponArys)
//    {
//        CZJEvalutionsForm* form = [[CZJEvalutionsForm alloc]initWithDictionary:dict];
//        switch (type)
//        {
//            case CZJEvalutionTypeAll:
//                [_userEvalutionAllForms addObject:form];
//                break;
//            case CZJEvalutionTypePic:
//                [_userEvalutionWithPicForms addObject:form];
//                break;
//            case CZJEvalutionTypeGood:
//                [_userEvalutionGoodForms addObject:form];
//                break;
//            case CZJEvalutionTypeMiddle:
//                [_userEvalutionMiddleForms addObject:form];
//                break;
//            case CZJEvalutionTypeBad:
//                [_userEvalutionBadForms addObject:form];
//                break;
//                
//            default:
//                break;
//        }
//    }
//}
//
//- (void)setEvalutionReplyWithDictionary:(NSDictionary*)dict
//{
//    [_userEvalutionReplyForms removeAllObjects];
//    [self appendEvalutionReplyWithDictionary:dict];
//}
//
//- (void)appendEvalutionReplyWithDictionary:(NSDictionary*)dict
//{
//    NSArray* couponArys = [dict valueForKey:@"msg"] ;
//    for (NSDictionary* dict in couponArys)
//    {
//        CZJEvalutionReplyForm* form = [[CZJEvalutionReplyForm alloc]initWithDictionary:dict];
//        [_userEvalutionReplyForms addObject:form];
//    }
//}
//
//- (void)resetData
//{
//    self.storeInfo = nil;
//    self.evalutionInfo = nil;
//    self.goodsDetail = nil;
//    self.serviceDetail = nil;
//    [_couponForms removeAllObjects];
//    [_recommendServiceForms removeAllObjects];
//}

@end

//@implementation CZJCouponForm
//@synthesize validServiceName = _validServiceName;
//@synthesize validStartTime = _validStartTime;
//@synthesize storeName = _storeName;
//@synthesize validServiceId = _validServiceId;
//@synthesize taked = _taked;
//@synthesize name = _name;
//@synthesize value = _value;
//@synthesize validEndTime = _validEndTime;
//@synthesize couponId = _couponId;
//@synthesize type = _type;
//@synthesize validMoney = _validMoney;
//@synthesize storeId = _storeId;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        self.validServiceName = [dict valueForKey:@"validServiceName"];
//        self.validStartTime = [dict valueForKey:@"validStartTime"];
//        self.storeName = [dict valueForKey:@"storeName"];
//        self.validServiceId = [dict valueForKey:@"validServiceId"];
//        self.taked = [[dict valueForKey:@"taked"] boolValue];
//        self.name = [dict valueForKey:@"name"];
//        self.value = [dict valueForKey:@"value"];
//        self.validEndTime = [dict valueForKey:@"validEndTime"];
//        self.couponId = [dict valueForKey:@"couponId"];
//        self.type = [dict valueForKey:@"type"];
//        self.validMoney = [dict valueForKey:@"validMoney"];
//        self.storeId = [dict valueForKey:@"storeId"];
//        return self;
//    }
//    return nil;
//}
//@end
//
//@implementation CZJStoreInfoForm
//
//@synthesize storeAddr = _storeAddr;
//@synthesize logo = _logo;
//@synthesize storeName = _storeName;
//@synthesize attentionCount = _attentionCount;
//@synthesize attentionFlag = _attentionFlag;
//@synthesize callCenterCount = _callCenterCount;
//@synthesize serviceCount = _serviceCount;
//@synthesize goodsCount = _goodsCount;
//@synthesize storeId = _storeId;
//@synthesize callCenterType = _callCenterType;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        self.storeAddr = [dict valueForKey:@"storeAddr"];
//        self.logo = [dict valueForKey:@"logo"];
//        self.storeName = [dict valueForKey:@"storeName"];
//        self.attentionCount = [dict valueForKey:@"attentionCount"];
//        self.attentionFlag = [[dict valueForKey:@"attentionFlag"] boolValue];
//        self.callCenterCount = [dict valueForKey:@"callCenterCount"];
//        self.serviceCount = [dict valueForKey:@"serviceCount"];
//        self.goodsCount = [dict valueForKey:@"goodsCount"];
//        self.storeId = [dict valueForKey:@"storeId"];
//        self.callCenterType = [dict valueForKey:@"callCenterType"];
//        return self;
//    }
//    return nil;
//}
//
//@end
//
//
//@implementation CZJServiceDetail
//@synthesize imgs = _imgs;
//@synthesize purchaseCount = _purchaseCount;
//@synthesize costPrice = _costPrice;
//@synthesize itemName = _itemName;
//@synthesize originalPrice = _originalPrice;
//@synthesize counterKey = _counterKey;
//@synthesize storeItemPid = _storeItemPid;
//@synthesize goHouseFlag = _goHouseFlag;
//@synthesize attentionFlag = _attentionFlag;
//@synthesize currentPrice = _currentPrice;
//@synthesize itemCode = _itemCode;
//@synthesize companyId = _companyId;
//@synthesize selfFlag = _selfFlag;
//@synthesize buyType = _buyType;
//@synthesize itemType = _itemType;
//@synthesize itemImg = _itemImg;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        self.imgs = [dict valueForKey:@"imgs"];
//        self.purchaseCount = [dict valueForKey:@"purchaseCount"];
//        self.costPrice = [dict valueForKey:@"costPrice"];
//        self.itemName = [dict valueForKey:@"itemName"];
//        self.originalPrice = [dict valueForKey:@"originalPrice"];
//        self.counterKey = [dict valueForKey:@"counterKey"];
//        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
//        self.goHouseFlag = [[dict valueForKey:@"goHouseFlag"] boolValue];
//        self.attentionFlag = [[dict valueForKey:@"attentionFlag"] boolValue];
//        self.selfFlag = [[dict valueForKey:@"selfFlag"] boolValue];
//        self.currentPrice = [dict valueForKey:@"currentPrice"];
//        self.itemCode = [dict valueForKey:@"itemCode"];
//        self.companyId = [dict valueForKey:@"companyId"];
//        self.buyType = [dict valueForKey:@"buyType"];
//        self.itemType = [dict valueForKey:@"itemType"];
//        self.itemImg = [dict valueForKey:@"itemImg"];
//        return self;
//    }
//    return nil;
//}
//
//@end
//
//@implementation CZJDetailEvalInfo
//@synthesize poorCount = _poorCount;
//@synthesize evalList = _evalList;
//@synthesize goodCount = _goodCount;
//@synthesize goodRate = _goodRate;
//@synthesize evalCount = _evalCount;
//@synthesize hasImgCount = _hasImgCount;
//@synthesize normalCount = _normalCount;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        self.evalList = [NSMutableArray array];
//        self.poorCount = [dict valueForKey:@"poorCount"];
//        NSArray* evals = [dict valueForKey:@"evalList"];
//        for (NSDictionary* dict in evals)
//        {
//            CZJEvalutionsForm* form = [[CZJEvalutionsForm alloc]initWithDictionary:dict];
//            [self.evalList addObject:form];
//        }
//        self.goodCount = [dict valueForKey:@"goodCount"];
//        self.goodRate = [dict valueForKey:@"goodRate"];
//        self.evalCount = [dict valueForKey:@"evalCount"];
//        self.hasImgCount = [dict valueForKey:@"hasImgCount"];
//        self.normalCount = [dict valueForKey:@"normalCount"];
//        return self;
//    }
//    return nil;
//}
//
//@end
//
@implementation CZJEvalutionsForm

@synthesize evalutionId = _evalutionId;
@synthesize imgs = _imgs;
@synthesize replyCount = _replyCount;
@synthesize evalStar = _evalStar;
@synthesize evalTime = _evalTime;
@synthesize evalDesc = _evalDesc;
@synthesize evalHead = _evalHead;
@synthesize evalName = _evalName;
@synthesize purchaseItem = _purchaseItem;
@synthesize purchaseTime = _purchaseTime;

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.evalutionId = [dict valueForKey:@"id"];
        self.imgs = [dict valueForKey:@"imgs"];
        self.replyCount = [dict valueForKey:@"replyCount"];
        self.evalStar = [dict valueForKey:@"evalStar"];
        self.evalTime = [dict valueForKey:@"evalTime"];
        self.evalDesc = [dict valueForKey:@"evalDesc"];
        self.evalHead = [dict valueForKey:@"evalHead"];
        self.evalName = [dict valueForKey:@"evalName"];
        self.purchaseItem = [dict valueForKey:@"purchaseItem"];
        self.purchaseTime = [dict valueForKey:@"purchaseTime"];
        return self;
    }
    return nil;
}

@end
//
//
@implementation CZJEvalutionReplyForm
@synthesize replyDesc = _replyDesc;
@synthesize replyHead = _replyHead;
@synthesize replyTime = _replyTime;
@synthesize replyId = _replyId;
@synthesize replyName = _replyName;


- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.replyDesc = [dict valueForKey:@"replyDesc"];
        self.replyHead = [dict valueForKey:@"replyHead"];
        self.replyTime = [dict valueForKey:@"replyTime"];
        self.replyId = [dict valueForKey:@"replyId"];
        self.replyName = [dict valueForKey:@"replyName"];
        return self;
    }
    return nil;
}

@end
//
//@implementation CZJGoodsDetail
//
//@end
//
//@implementation CZJGoodsSKU
//@synthesize skuPrice = _skuPrice;
//@synthesize skuStock = _skuStock;
//@synthesize skuName = _skuName;
//@synthesize skuCode = _skuCode;
//@synthesize skuImg = _skuImg;
//@synthesize skuValueIds = _skuValueIds;
//@synthesize skuValues = _skuValues;
//
//- (id)initWithDictionary:(NSDictionary*)dict
//{
//    if (self = [super init])
//    {
//        self.skuPrice = [dict valueForKey:@"skuPrice"];
//        self.skuStock = [dict valueForKey:@"skuStock"];
//        self.skuName = [dict valueForKey:@"skuName"];
//        self.skuCode = [dict valueForKey:@"skuCode"];
//        self.skuImg = [dict valueForKey:@"skuImg"];
//        self.skuValueIds = [dict valueForKey:@"skuValueIds"];
//        self.skuValues = [dict valueForKey:@"skuValues"];
//        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
//        return self;
//    }
//    return nil;
//}
//@end