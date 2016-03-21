//
//  CZJAttentionForm.m
//  CZJShop
//
//  Created by Joe.Pen on 1/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAttentionForm.h"

@implementation CZJGoodsAttentionForm

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.chezhuId = [dict valueForKey:@"chezhuId"];
        self.createTime = [dict valueForKey:@"createTime"];
        self.currentPrice = [dict valueForKey:@"currentPrice"];
        self.attentionID = [dict valueForKey:@"id"];
        self.itemImg = [dict valueForKey:@"itemImg"];
        self.itemName = [dict valueForKey:@"itemName"];
        self.itemType = [dict valueForKey:@"itemType"];
        self.storeItemPid = [dict valueForKey:@"storeItemPid"];
        self.isSelected = NO;
        return self;
    }
    return nil;
}
@end

@implementation CZJStoreAttentionForm

- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.attentionCount = [dict valueForKey:@"attentionCount"];
        self.chezhuId = [dict valueForKey:@"chezhuId"];
        self.createTime = [dict valueForKey:@"createTime"];
        self.homeImg = [dict valueForKey:@"homeImg"];
        self.attentionID = [dict valueForKey:@"id"];
        self.name = [dict valueForKey:@"name"];
        self.storeId = [dict valueForKey:@"storeId"];
        self.isSelected = NO;
        return self;
    }
    return nil;
}


@end
