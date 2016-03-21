//
//  CZJMyCardInfoForm.m
//  CZJShop
//
//  Created by Joe.Pen on 2/18/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyCardInfoForm.h"

@implementation CZJMyCardInfoForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJMyCardDetailInfoForm"};
}
@end

@implementation CZJMyCardDetailInfoForm
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{@"ID" : @"id",};
}
@end


@implementation CZJCardDetailInfoForm
+ (NSDictionary *)objectClassInArray
{
    return @{@"items" : @"CZJCardDetailInfoFormItem"};
}
@end

@implementation CZJCardDetailInfoFormItem
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{@"ID" : @"id",};
}
@end