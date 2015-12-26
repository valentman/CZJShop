//
//  CZJReceiveCouponsController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"
@interface CZJReceiveCouponsController : CZJFilterBaseController
@property (nonatomic, copy) MGBasicBlock basicBlock;

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
- (void)setCouponsAry:(NSMutableArray*)coupons;
@end
