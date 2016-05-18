//
//  CZJMessageOrderController.h
//  CZJShop
//
//  Created by Joe.Pen on 5/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMessageOrderListDelegate <NSObject>

- (void)clickMessageOneOrder:(CZJOrderListForm*)orderListForm;
@end

@interface CZJMessageOrderController : CZJViewController
@property (weak, nonatomic) id<CZJMessageOrderListDelegate> delegate;
@property (strong, nonatomic) NSString* storeId;
@end
