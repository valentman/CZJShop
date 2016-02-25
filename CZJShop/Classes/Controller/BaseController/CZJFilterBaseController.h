//
//  CZJFilterBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMGLeftSpace 50
@interface CZJFilterBaseController : UIViewController
{
     CZJCarListType _carlistType;
}
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView* topView;
@property (assign, nonatomic)CZJCarListType carlistType;

- (UIBarButtonItem *)spacerWithSpace:(CGFloat)space;
- (void)navBackBarAction:(UIBarButtonItem *)bar;
- (void)cancelAction:(UIBarButtonItem *)bar;
- (instancetype)initWithType:(CZJCarListType)type;
@end
