//
//  CZJSBAlertView.h
//  CZJShop
//
//  Created by Joe.Pen on 2/24/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJAlertView.h"

@interface CZJSBAlertView : UIViewController
@property (nonatomic, strong)CZJAlertView* popView;
- (void)setConfirmItemHandle:(CZJGeneralBlock)basicBlock;
@end
