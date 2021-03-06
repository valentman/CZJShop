//
//  CZJMyWalletCouponController.h
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyWalletCouponController : CZJViewController

@end



@interface CZJMyWalletCouponListBaseController : UIViewController
{
    NSMutableDictionary* _params;
    NSInteger _couponType;
}
@property (assign, nonatomic)NSInteger couponType;
@property (strong, nonatomic)NSMutableDictionary* params;

- (void)getCouponListFromServer;
@end


@interface CZJMyWalletCouponUnUsedController : CZJMyWalletCouponListBaseController

@end

@interface CZJMyWalletCouponUsedController : CZJMyWalletCouponListBaseController

@end

@interface CZJMyWalletCouponOutOfTimeController : CZJMyWalletCouponListBaseController

@end



