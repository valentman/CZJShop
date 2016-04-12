//
//  CZJOrderCouponCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderCouponCell.h"



@implementation CZJOrderCouponCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.orderCouponsScrollViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 110;
    self.orderCouponScrollView.scrollEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setUseableCouponAry:(NSMutableArray*)useableAry
{
    [_orderCouponScrollView removeAllSubViews];
    
    for (int i  = 0; i < useableAry.count; i++) {
        float height = 36;
        float width = height * 144/64;
        
        CGRect frame = CGRectMake(i * (width+10), 5, width, height);
        CZJCouponBarItemView* view = [[CZJCouponBarItemView alloc]initWithFrame:frame AndData:useableAry[i]];
        [view setTag:i + 2000];
        
        //信息条顺序往下添加
        [_orderCouponScrollView addSubview:view];
    }
}
@end
