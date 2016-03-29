//
//  CZJGoodsListFilterController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"

@interface CZJGoodsListFilterController : CZJFilterBaseController
@property (nonatomic,weak)id<CZJFilterControllerDelegate>delegate;
@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSArray* selectedConditionArys;
- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
@end
