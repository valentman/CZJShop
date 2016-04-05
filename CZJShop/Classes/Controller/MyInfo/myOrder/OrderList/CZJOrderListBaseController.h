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
    NSMutableDictionary* _params;
    NSString* _noDataPrompt;
}
@property (strong, nonatomic)NSMutableDictionary* params;
@property (strong, nonatomic)NSString* noDataPrompt;
@property (weak, nonatomic)id<CZJOrderListDelegate> delegate;
@property (strong, nonatomic)CZJOrderListNoPayButtomView* noPayButtomView;

- (void)initMyDatas;
- (void)getOrderListFromServer;
- (void)removeOrderlistControllerNotification;
@end


@interface CZJOrderListAllController : CZJOrderListBaseController
@end


@interface CZJOrderListNoPayController : CZJOrderListBaseController
@end


@interface CZJOrderListNoBuildController : CZJOrderListBaseController
@end


@interface CZJOrderListNoReceiveController : CZJOrderListBaseController
@end


@interface CZJOrderListNoEvaController : CZJOrderListBaseController
@end
