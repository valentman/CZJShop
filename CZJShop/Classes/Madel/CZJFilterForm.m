//
//  CZJFilterForm.m
//  CZJShop
//
//  Created by Joe.Pen on 3/28/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJFilterForm.h"

@implementation CZJFilterBaseForm
- (id)init
{
    if (self = [super init]) {
        self.selectedItems = [NSMutableArray array];
        return self;
    }
    return nil;
}
@end


@implementation CZJFilterBrandForm

+ (NSDictionary*)objectClassInArray
{
    return @{@"items" : @"CZJFilterBrandItemForm"};
}
@end

@implementation CZJFilterBrandItemForm
@end


@implementation CZJFilterPriceForm
@end

@implementation CZJFilterPriceItemForm
@end


@implementation CZJFilterCategoryForm
+ (NSDictionary*)objectClassInArray
{
    return @{@"items" : @"CZJFilterCategoryItemForm"};
}
@end

@implementation CZJFilterCategoryItemForm
@end


