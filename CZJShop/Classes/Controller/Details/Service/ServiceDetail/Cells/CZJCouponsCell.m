//
//  CZJCouponsCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCouponsCell.h"

@implementation CZJCouponsCell

- (void)awakeFromNib {
    // Initialization code
    couponsAry = [NSArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithCouponDatas:(NSArray*)coupons
{
    self.isInit = YES;
    couponsAry = coupons;
}

@end
