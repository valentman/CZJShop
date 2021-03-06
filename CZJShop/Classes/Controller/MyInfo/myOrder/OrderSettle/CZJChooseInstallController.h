//
//  CZJChooseInstallController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJChooseInstallControllerDelegate <NSObject>

- (void)clickSelectInstallStore:(id)sender;

@end

@interface CZJChooseInstallController : CZJViewController

@property (strong, nonatomic) NSString* storeItemPid;
@property (strong, nonatomic) CZJOrderGoodsForm* orderGoodsForm;
@property (weak, nonatomic) id<CZJChooseInstallControllerDelegate> delegate;
@end
