//
//  CZJDeliveryAddrController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"

@protocol CZJDeliveryAddrControllerDelegate <NSObject>

- (void)clickChooseAddr:(CZJAddrForm*)addForm;
@end

@interface CZJDeliveryAddrController : CZJViewController
@property (strong, nonatomic)NSString* currentAddrId;
@property (strong, nonatomic)NSString* viewFrom;
@property (weak, nonatomic)id<CZJDeliveryAddrControllerDelegate> delegate;

- (void)getAddrListDataFromServer;
@end
