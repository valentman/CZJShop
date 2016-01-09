//
//  CZJOrderCouponCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJShoppingCartForm.h"


@interface CouponBarView : UIView
- (instancetype)initWithFrame:(CGRect)frame AndData:(CZJShoppingCouponsForm*)data;
@end

@interface CZJOrderCouponCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderCouponImg;
@property (weak, nonatomic) IBOutlet UIScrollView *orderCouponScrollView;

- (void)setUseableCouponAry:(NSMutableArray*)useableAry;

@end
