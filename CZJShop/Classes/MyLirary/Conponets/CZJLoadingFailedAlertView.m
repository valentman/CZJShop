//
//  CZJLoadingFailedAlertView.m
//  CZJShop
//
//  Created by Joe.Pen on 3/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJLoadingFailedAlertView.h"

@implementation CZJLoadingFailedAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.reloadBtn addTarget:self action:@selector(reloadNetWork) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRoloadHandle:(CZJGeneralBlock)reloadHandle
{
    self.reloadHandle = reloadHandle;
}

- (void)reloadNetWork
{
    if (self.reloadHandle)
    {
        self.reloadHandle();
    }
//    if (self.superview)
//    {
//        [self removeFromSuperview];
//    }
    
}

@end
