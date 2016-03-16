//
//  CZJCouponsCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJCouponsCell : CZJTableViewCell
{
    NSArray* couponsAry;
}
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coupontNameWidth;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (weak, nonatomic) IBOutlet UILabel *myDetailLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *couponScrollView;


- (void)initWithCouponDatas:(NSArray*)coupons;
@end


@interface CZJCouponView : UIView
@property (strong, nonatomic)UIImageView* bgImage;
@property (strong, nonatomic)UILabel* couponInfoLabel;

- (id)initWithFrame:(CGRect)frame;
@end