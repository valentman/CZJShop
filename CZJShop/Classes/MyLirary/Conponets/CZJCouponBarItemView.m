//
//  CZJCouponBarItemView.m
//  CZJShop
//
//  Created by Joe.Pen on 3/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJCouponBarItemView.h"

@implementation CZJCouponBarItemView
- (instancetype)initWithFrame:(CGRect)frame AndData:(CZJShoppingCouponsForm*)data
{
    if (self  = [super initWithFrame:frame])
    {
        float frameWidth = frame.size.width;
        float frameHeight = frame.size.height;
        
        //背景框图
        NSString* imgName = [data.type isEqualToString:@"3"] ? @"coupon_icon_blue" : @"coupon_icon_red";
        UIImageView* bgImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imgName]];
        bgImg.frame =  CGRectMake(5 , frame.origin.y, frameWidth, frameHeight);
        [self addSubview:bgImg];
        
        //店名
        UILabel* label_storeName = [[UILabel alloc] init];
        label_storeName.textAlignment = NSTextAlignmentCenter;
        label_storeName.font = [UIFont systemFontOfSize:11.0f];;
        label_storeName.text = data.storeName;
        label_storeName.textColor = [data.type isEqualToString:@"3"] ? CZJBLUECOLOR : CZJREDCOLOR;
        label_storeName.frame =  CGRectMake(10 , 7, frameWidth - 15, 15);
        [self addSubview:label_storeName];
        
        //优惠值
        UILabel* label_value = [[UILabel alloc] init];
        label_value.textAlignment = NSTextAlignmentCenter;
        label_value.font = [UIFont systemFontOfSize:11.0f];
        NSString* typestr = [data.type isEqualToString:@"1"] ? [NSString stringWithFormat:@"￥%@代金券",data.value] : [NSString stringWithFormat:@"%@",data.name];
        label_value.text = typestr;
        label_value.textColor = [data.type isEqualToString:@"3"] ? CZJBLUECOLOR : CZJREDCOLOR;
        label_value.frame = CGRectMake(10 , frameHeight - 12, frameWidth - 10, 15);
        [self addSubview:label_value];
        
        return self;
    }
    return nil;
}
@end