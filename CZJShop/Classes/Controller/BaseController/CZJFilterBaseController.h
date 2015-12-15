//
//  CZJFilterBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJFilterBaseController : UIViewController
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView* topView;
- (UIBarButtonItem *)spacerWithSpace:(CGFloat)space;
- (void)navBackBarAction:(UIBarButtonItem *)bar;
- (void)cancelAction:(UIBarButtonItem *)bar;

@end
