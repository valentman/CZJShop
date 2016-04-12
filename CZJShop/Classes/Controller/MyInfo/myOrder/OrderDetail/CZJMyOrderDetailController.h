//
//  CZJMyOrderDetailController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"
@interface CZJMyOrderDetailController : CZJViewController
@property (strong, nonatomic)NSString* orderNo;
@property (strong, nonatomic)CZJReturnedOrderListForm* returnedGoodsForm;
@property (strong, nonatomic)NSString* stageStr;
@property (assign, nonatomic)CZJOrderDetailType orderDetailType;
@end
