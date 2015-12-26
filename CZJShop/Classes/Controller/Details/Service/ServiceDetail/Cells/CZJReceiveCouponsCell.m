//
//  CZJReceiveCouponsCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/26/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJReceiveCouponsCell.h"

@implementation CZJReceiveCouponsCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellIsTaken:(BOOL)taken andServiceType:(BOOL)isService;
{
    UIColor* untakenColor = isService ? [UIColor blueColor] : [UIColor redColor];
    UIColor* textColor = taken ? [UIColor grayColor] : untakenColor;
    self.couponPriceLabel.textColor = textColor;
    self.storeNameLabel.textColor = textColor;
    if (taken)
    {
        [self.couponBgImg setImage:IMAGENAMED(@"coupon_icon_base_gray")];
        self.receivedImg.hidden = NO;
    }
    else
    {
        NSString* imageName = isService ? @"coupon_icon_base_blue" : @"coupon_icon_base_red";
        [self.couponBgImg setImage:IMAGENAMED(imageName)];
        self.receivedImg.hidden = YES;
    }
}


@end
