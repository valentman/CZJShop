//
//  CALayer+UIColor.m
//  CZJShop
//
//  Created by Joe.Pen on 1/30/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CALayer+UIColor.h"

@implementation CALayer (Color)
- (void)setBorderColorWithUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end
