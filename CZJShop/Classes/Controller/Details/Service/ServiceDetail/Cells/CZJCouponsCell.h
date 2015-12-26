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


- (void)initWithCouponDatas:(NSArray*)coupons;
@end
