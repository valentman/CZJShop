//
//  CZJGoodsListFilterSubController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"


@protocol CZJGoodsListFilterSubControllerDelegate <NSObject>

- (void)sendChoosedDataBack:(id)data;

@end

@interface CZJGoodsListFilterSubController : CZJFilterBaseController
@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSString* subFilterName;
@property (strong, nonatomic) NSArray* subFilterArys;
@property (strong, nonatomic) NSMutableArray* selectdCondictionArys;
@property (weak, nonatomic) id<CZJGoodsListFilterSubControllerDelegate>delegate;
@end
