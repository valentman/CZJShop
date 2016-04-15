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
    self.couponPriceLabel.keyWordFont = SYSTEMFONT(30);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellIsTaken:(BOOL)taken andServiceType:(BOOL)isService
{
    UIColor* untakenColor = isService ? CZJBLUECOLOR : CZJREDCOLOR;
    UIColor* textColor = taken ? [UIColor grayColor] : untakenColor;
    self.couponPriceLabel.textColor = textColor;
    self.storeNameLabel.textColor = textColor;
    self.couponPriceLabel.font = isService ? SYSTEMFONT(30) : SYSTEMFONT(45);
    self.couponPriceLabelLeading.constant = isService ? 10 : 0;
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

- (void)setCellWithCouponType:(NSInteger)couponType andServiceType:(BOOL)isService
{
    UIColor* untakenColor;
    switch (couponType)
    {
        case 0:
        {
            untakenColor = isService ? CZJBLUECOLOR : CZJREDCOLOR;
            NSString* imageName = isService ? @"coupon_icon_base_blue" : @"coupon_icon_base_red";
            [self.couponBgImg setImage:IMAGENAMED(imageName)];
        }
            break;
        case 1:
            untakenColor = CZJGRAYCOLOR;
            [self.couponBgImg setImage:IMAGENAMED(@"coupon_icon_base_gray")];
            self.receivedImg.hidden = NO;
            [self.receivedImg setImage:IMAGENAMED(@"coupon_icon_shiyong")];
            break;
        case 2:
            untakenColor = CZJGRAYCOLOR;
            [self.couponBgImg setImage:IMAGENAMED(@"coupon_icon_base_gray")];
            self.receivedImg.hidden = NO;
            [self.receivedImg setImage:IMAGENAMED(@"couponl_icon_guoqi")];
            break;
            
        default:
            break;
    }
    self.couponPriceLabel.textColor = untakenColor;
    self.storeNameLabel.textColor = untakenColor;
}


@end
