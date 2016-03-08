//
//  CZJChooseCouponController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJChooseCouponControllerDelegate <NSObject>

- (void)clickToConfirmUse;

@end


@interface CZJChooseCouponController : CZJViewController
{
    NSString* _storeIds;
}
@property (strong, nonatomic) NSString* storeIds;
@property (weak, nonatomic)id<CZJChooseCouponControllerDelegate> delegate;
@end
