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
        
        NSString* priceStri;
        switch ([data.type integerValue])
        {
            case 1://代金券
                priceStri = [NSString stringWithFormat:@"￥%d代金券",[data.value intValue]];
                break;
                
            case 2://满减券
                priceStri = [NSString stringWithFormat:@"满%@减%@",data.validMoney,data.value];
                break;
                
            case 3://项目券
                priceStri = @"项目券";
                break;
                
            default:
                break;
        }
        label_value.text = priceStri;
        label_value.textColor = [data.type isEqualToString:@"3"] ? CZJBLUECOLOR : CZJREDCOLOR;
        label_value.frame = CGRectMake(10 , frameHeight - 12, frameWidth - 10, 15);
        [self addSubview:label_value];
        
        return self;
    }
    return nil;
}
@end