//
//  CZJCouponsCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCouponsCell.h"
#import "CZJGoodsDetailForm.h"

@implementation CZJCouponsCell

- (void)awakeFromNib {
    [super awakeFromNib];
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
    
    [_couponScrollView removeAllSubViews];
    
    for (int i  = 0; i < couponsAry.count; i++) {
        float height = 36;
        float width = height * 144/64;
        
        CGRect frame = CGRectMake(i * (width+10), 5, width, height);
        CZJCouponBarItemView* view = [[CZJCouponBarItemView alloc]initWithFrame:frame AndData:couponsAry[i]];
        [view setTag:i + 2000];
        
        //信息条顺序往下添加
        [_couponScrollView addSubview:view];
    }
}

@end
