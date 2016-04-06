//
//  CZJMyWalletCardController.h
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyWalletCardController : CZJViewController

@end


@protocol CZJMyWalletCardListCellDelegate <NSObject>

- (void)clickCardWithData:(id)data;

@end

@interface CZJMyWalletCardListBaseController : UIViewController
{
    NSMutableDictionary* _params;
}
@property (strong, nonatomic)NSMutableDictionary* params;
@property (weak, nonatomic) id<CZJMyWalletCardListCellDelegate> delegate;

- (void)initMyDatas;
- (void)getCardListFromServer;
@end


@interface CZJMyWalletCardUnUsedController : CZJMyWalletCardListBaseController

@end

@interface CZJMyWalletCardUsedController : CZJMyWalletCardListBaseController

@end