//
//  CZJImageView.m
//  CZJShop
//
//  Created by Joe.Pen on 4/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJImageView.h"

@implementation CZJImageView
- (id)initWithFrame:(CGRect)imageRect
{
    if (self == [super initWithFrame:imageRect])
    {
        self.userInteractionEnabled = YES;
        return self;
    }
    return nil;
}
@end
