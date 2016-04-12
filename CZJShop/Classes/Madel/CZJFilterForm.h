//
//  CZJFilterForm.h
//  CZJShop
//
//  Created by Joe.Pen on 3/28/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJFilterBaseForm : NSObject
@property (strong, nonatomic)NSString* name;
@property (strong, nonatomic)NSMutableArray* selectedItems;
- (id)init;
@end


@interface CZJFilterBrandForm : CZJFilterBaseForm
@property (strong, nonatomic)NSArray* items;

@end

@interface CZJFilterBrandItemForm : NSObject
@property (strong, nonatomic)NSString* brandId;
@property (strong, nonatomic)NSString* initial;
@property (strong, nonatomic)NSString* name;
@end


@interface CZJFilterPriceForm : CZJFilterBaseForm
@end

@interface CZJFilterPriceItemForm :NSObject
@property (strong, nonatomic)NSString* endPrice;
@property (strong, nonatomic)NSString* name;
@property (strong, nonatomic)NSString* startPrice;
@end


@interface CZJFilterCategoryForm : CZJFilterBaseForm
@property (strong, nonatomic)NSString* attrId;
@property (strong, nonatomic)NSArray* items;
@property (strong, nonatomic)NSString* singleFlag;
@end

@interface CZJFilterCategoryItemForm : NSObject
@property (strong, nonatomic)NSString*  attrId;
@property (strong, nonatomic)NSString*  value;
@property (strong, nonatomic)NSString*  valueId;
@end
