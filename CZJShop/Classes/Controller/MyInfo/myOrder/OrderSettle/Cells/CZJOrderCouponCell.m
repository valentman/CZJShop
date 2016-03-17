//
//  CZJOrderCouponCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderCouponCell.h"

@implementation CouponBarView
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
        label_storeName.textColor = [UIColor redColor];
        label_storeName.frame =  CGRectMake(5 , 5, frameWidth - 10, 15);
        [self addSubview:label_storeName];
        
        //优惠值
        UILabel* label_value = [[UILabel alloc] init];
        label_value.textAlignment = NSTextAlignmentCenter;
        label_value.font = [UIFont systemFontOfSize:11.0f];;
        label_value.text = [NSString stringWithFormat:@"￥%@",data.value];
        label_value.textColor = [UIColor redColor];
        label_value.frame = CGRectMake(5 , frameHeight - 15, frameWidth - 10, 15);
        [self addSubview:label_value];
        
        return self;
    }
    return nil;
}
@end

@implementation CZJOrderCouponCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.orderCouponsScrollViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 110;
    self.orderCouponScrollView.scrollEnabled = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUseableCouponAry:(NSMutableArray*)useableAry
{
    [_orderCouponScrollView removeAllSubViews];
    
    for (int i  = 0; i < useableAry.count; i++) {
        float height = _orderCouponScrollView.frame.size.height;
        float width = height * 144/64;
        
        CGRect frame = CGRectMake(i * (width+10), 0, width, height);
        CouponBarView* view = [[CouponBarView alloc]initWithFrame:frame AndData:useableAry[i]];
        [view setTag:i + 2000];
        
        //信息条顺序往下添加
        [_orderCouponScrollView addSubview:view];
    }
}
@end
