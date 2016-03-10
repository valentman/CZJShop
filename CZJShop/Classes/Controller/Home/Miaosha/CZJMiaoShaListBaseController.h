//
//  CZJMiaoShaListBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMiaoShaListDelegate <NSObject>

//- (void)clickOneOrder:(CZJOrderListForm*)orderListForm;
//- (void)clickOrderListCellButton:(UIButton*)sender
//                   andButtonType:(CZJOrderListCellButtonType)buttonType
//                    andOrderForm:(CZJOrderListForm*)orderListForm;
//- (void)showPopPayView:(float)orderMoney;

@end

@interface CZJMiaoShaListBaseController : CZJViewController
{
    NSDictionary* _params;
}
@property (strong, nonatomic)NSDictionary* params;
@property (weak, nonatomic)id<CZJMiaoShaListDelegate> delegate;

- (void)getMiaoShaDataFromServer;
@end

@interface CZJMiaoShaOneController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaTwoController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaThreeController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaFourController : CZJMiaoShaListBaseController
@end

@interface CZJMiaoShaFiveController : CZJMiaoShaListBaseController
@end