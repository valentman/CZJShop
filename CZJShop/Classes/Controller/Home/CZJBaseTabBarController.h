//
//  CZJBaseTabBarController.h
//  CZJShop
//
//  Created by Joe.Pen on 3/15/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJBaseTabBarController : UITabBarController<UITabBarControllerDelegate>
{
    //最近一次选择的Index
    NSUInteger _lastSelectedIndex;
}
@property(readonly, nonatomic) NSUInteger lastSelectedIndex;
@end
