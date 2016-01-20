//
//  CZJViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/22/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJNaviagtionBarView.h"


@interface CZJViewController : UIViewController<CZJViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *upView;
@property (nonatomic, strong) CZJNaviagtionBarView* naviBarView;

- (void)addCZJNaviBarView;
@end
