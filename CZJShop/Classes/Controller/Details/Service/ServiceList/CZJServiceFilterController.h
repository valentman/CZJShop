//
//  CZJServiceFilterController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"

@interface CZJServiceFilterController : CZJFilterBaseController
@property (nonatomic,weak)id<CZJFilterControllerDelegate>delegate;
- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
@end
