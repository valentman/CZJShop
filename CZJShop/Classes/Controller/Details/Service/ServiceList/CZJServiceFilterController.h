//
//  CZJServiceFilterController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"

@protocol CZJServiceFilterDelegate <NSObject>

- (void)chooseFilterOK;

@end

@interface CZJServiceFilterController : CZJFilterBaseController
@property (nonatomic,weak)id<CZJServiceFilterDelegate>delegate;
- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
@end
