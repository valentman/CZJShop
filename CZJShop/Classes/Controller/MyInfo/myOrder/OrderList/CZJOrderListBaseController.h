//
//  CZJOrderListBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"

@protocol CZJOrderListDelegate <NSObject>

- (void)clickOneOrder:(CZJOrderListForm*)orderListForm;

@end

@interface CZJOrderListBaseController : UIViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;
@property (weak, nonatomic)id<CZJOrderListDelegate> delegate;
- (void)getOrderListFromServer;
@end
