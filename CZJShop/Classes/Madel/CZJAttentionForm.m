//
//  CZJAttentionForm.m
//  CZJShop
//
//  Created by Joe.Pen on 1/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAttentionForm.h"

@implementation CZJGoodsAttentionForm
+(NSDictionary*)replacedKeyFromPropertyName
{
    return @{@"attentionID" : @"id"};
}
- (id)init
{
    if (self = [super init])
    {
        self.isSelected = NO;
        return self;
    }
    return nil;
}
@end


@implementation CZJStoreAttentionForm
+(NSDictionary*)replacedKeyFromPropertyName
{
    return @{@"attentionID" : @"id"};
}
- (id)init
{
    if (self = [super init])
    {
        self.isSelected = NO;
        return self;
    }
    return nil;
}


@end
