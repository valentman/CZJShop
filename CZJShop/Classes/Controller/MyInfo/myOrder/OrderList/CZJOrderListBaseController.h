//
//  CZJOrderListBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/29/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"
#import "CZJOrderListCell.h"
#import "CZJOrderListNoPayButtomView.h"

@protocol CZJOrderListDelegate <NSObject>

- (void)clickOneOrder:(CZJOrderListForm*)orderListForm;
- (void)clickOrderListCellButton:(UIButton*)sender
                   andButtonType:(CZJOrderListCellButtonType)buttonType
                    andOrderForm:(CZJOrderListForm*)orderListForm;
- (void)showPopPayView:(float)orderMoney andOrderNoSting:(NSString*)orderNostr;

@end

@interface CZJOrderListBaseController : UIViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;
@property (weak, nonatomic)id<CZJOrderListDelegate> delegate;
@property (strong, nonatomic)CZJOrderListNoPayButtomView* noPayButtomView;

- (void)getOrderListFromServer;
@end
