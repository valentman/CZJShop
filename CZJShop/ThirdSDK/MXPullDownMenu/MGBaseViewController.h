//
//  MGBaseViewController.h
//  JDSelectDemo
//
//  Created by mark on 15/8/3.
//  Copyright (c) 2015年 mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGBaseViewController : UIViewController
@property (nonatomic, strong) UILabel *lblTitle;
- (UIBarButtonItem *)spacerWithSpace:(CGFloat)space;
- (void)navBackBarAction:(UINavigationItem *)bar;
@end
