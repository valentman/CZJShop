//
//  CZJOrderListBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderListBaseController : UIViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;
- (void)getOrderListFromServer;
@end
