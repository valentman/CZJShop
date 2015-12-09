//
//  CZJStoreMAAroundForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJStoreMAAroundForm : NSObject
@property(nonatomic, strong) NSString *mname;//标题
@property(nonatomic, strong) NSNumber *price;//价格
@property(nonatomic, strong) NSString *imgurl;//图片

@property(nonatomic, strong) NSMutableArray *rdplocs;//坐标等

@end
