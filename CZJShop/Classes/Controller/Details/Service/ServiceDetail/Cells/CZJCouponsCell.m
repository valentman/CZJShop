//
//  CZJCouponsCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCouponsCell.h"
#import "CZJDetailForm.h"

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
    NSInteger count  = couponsAry.count;
    if (count >= 3) {
        count = 3;
    }
    int location = 63;
    for (int i = 0; i<count; i++)
    {
        CZJCouponForm* couponForm = couponsAry[i];
        NSString* couponname = couponForm.name;
        CGSize couponSize = [CZJUtils calculateTitleSizeWithString:couponname WithFont:SYSTEMFONT(12)];
        int _width = couponSize.width < 50 ? 50 : couponSize.width;
        CGRect rect = CGRectMake(location, 8, 100, 30);
        location += 100 + 5;
        CZJCouponView* view = [[CZJCouponView alloc]initWithFrame:rect];
        view.couponInfoLabel.text = couponForm.name;
        NSString* imagezname;
        if ([couponForm.type intValue] < 3) {
            imagezname = @"shop_icon_coupon_red";
        }
        else
        {
            imagezname = @"shop_icon_coupon_blue";
        }
        [view.bgImage setImage:IMAGENAMED(imagezname)];
        [self.contentView addSubview:view];
    }
}

@end


@implementation CZJCouponView
@synthesize bgImage = _bgImage;
@synthesize couponInfoLabel = _couponInfoLabel;

- (id)initWithFrame:(CGRect)frame
{

    if (self = [super initWithFrame:frame])
    {
        _bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _couponInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, frame.size.width, 20)];
        _couponInfoLabel.textColor = [UIColor whiteColor];
        _couponInfoLabel.font = SYSTEMFONT(12);
        _couponInfoLabel.textAlignment = NSTextAlignmentCenter;
        
        
        [self addSubview:_bgImage];
        [self addSubview:_couponInfoLabel];
        return self;
    }
    return nil;
}

@end