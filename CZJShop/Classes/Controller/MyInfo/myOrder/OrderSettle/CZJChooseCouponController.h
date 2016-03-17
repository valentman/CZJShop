//
//  CZJChooseCouponController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJChooseCouponControllerDelegate <NSObject>

- (void)clickToConfirmUse:(NSMutableArray*)choosedCouponAry;

@end


@interface CZJChooseCouponController : CZJViewController
@property (strong, nonatomic) NSArray* orderStores;
@property (strong, nonatomic) NSArray* choosedCoupons;
@property (weak, nonatomic)id<CZJChooseCouponControllerDelegate> delegate;
@end
