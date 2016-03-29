//
//  CZJOrderCouponCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJShoppingCartForm.h"

@interface CZJOrderCouponCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderCouponImg;
@property (weak, nonatomic) IBOutlet UIScrollView *orderCouponScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderCouponsScrollViewLayoutWidth;
@property (weak, nonatomic) IBOutlet UILabel *contentNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentNamelabelWidth;
@property (weak, nonatomic) IBOutlet UIImageView *contentImg;

- (void)setUseableCouponAry:(NSMutableArray*)useableAry;

@end
