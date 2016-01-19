//
//  CZJStoreDetailForm.m
//  CZJShop
//
//  Created by Joe.Pen on 1/15/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJStoreDetailForm.h"

@implementation CZJStoreDetailForm

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.attentionCount = [dict valueForKey:@"attentionCount"];
        self.attentionFlag = [[dict valueForKey:@"attentionFlag"]boolValue];
        self.cityId = [dict valueForKey:@"cityId"];
        self.companyId = [dict valueForKey:@"companyId"];
        self.contactAccount = [dict valueForKey:@"contactAccount"];
        self.contactName = [dict valueForKey:@"contactName"];
        self.contactType = [dict valueForKey:@"contactType"];
        self.deliveryScore = [dict valueForKey:@"deliveryScore"];
        self.descScore = [dict valueForKey:@"descScore"];
        self.environmentScore = [dict valueForKey:@"environmentScore"];
        self.goodsCount = [dict valueForKey:@"goodsCount"];
        self.hotline = [dict valueForKey:@"hotline"];
        self.lat = [dict valueForKey:@"lat"];
        self.lng = [dict valueForKey:@"lng"];
        self.promotionCount = [dict valueForKey:@"promotionCount"];
        self.serviceCount = [dict valueForKey:@"serviceCount"];
        self.serviceScore = [dict valueForKey:@"serviceScore"];
        self.setmenuCount = [dict valueForKey:@"setmenuCount"];
        self.storeAddr = [dict valueForKey:@"storeAddr"];
        self.storeId = [dict valueForKey:@"storeId"];
        self.storeName = [dict valueForKey:@"storeName"];
        return self;
    }
    return nil;
}

@end

@implementation CZJStoreDetailActivityForm

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.activityId = [dict valueForKey:@"activityId"];
        self.img = [dict valueForKey:@"img"];
        self.url = [dict valueForKey:@"url"];
        self.title = [dict valueForKey:@"title"];
        return self;
    }
    return nil;
}

@end

@implementation CZJStoreDetailBannerForm

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.bannerID = [dict valueForKey:@"id"];
        self.img = [dict valueForKey:@"img"];
        self.type = [dict valueForKey:@"type"];
        self.title = [dict valueForKey:@"title"];
        return self;
    }
    return nil;
}

@end


@implementation CZJStoreDetailTypesForm
- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.name = [dict valueForKey:@"name"];
        self.typeId = [dict valueForKey:@"typeId"];
        return self;
    }
    return nil;
}
@end


@implementation CZJSToreDetailGoodsAndServiceForm : NSObject

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        self.originalPrice = [dict valueForKey:@"originalPrice"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.itemImg = [dict valueForKey:@"itemImg"];
        self.itemName = [dict valueForKey:@"itemName"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        return self;
    }
    return nil;
}
@end
