//
//  CZJMyWalletCardController.h
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyWalletCardController : UIViewController

@end


@interface CZJMyWalletCardListBaseController : UIViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;

- (void)getCardListFromServer;
@end


@interface CZJMyWalletCardUnUsedController : CZJMyWalletCardListBaseController

@end

@interface CZJMyWalletCardUsedController : CZJMyWalletCardListBaseController

@end