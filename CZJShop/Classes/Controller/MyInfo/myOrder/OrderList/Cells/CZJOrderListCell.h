//
//  CZJOrderListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"

typedef NS_ENUM(NSInteger,CZJOrderType)
{
    CZJOrderTypeAll = 0,
    CZJOrderTypeNoPay,
    CZJOrderTypeNoBuild,
    CZJOrderTypeBuilding,
    CZJOrderTypeNoRecive,
    CZJOrderTypeNoEvalution,
    CZJOrderTypeAllDone
};

typedef NS_ENUM(NSInteger,CZJOrderListCellButtonType)
{
    CZJOrderListCellBtnTypeReturnAble = 0,      //可退换货
    CZJOrderListCellBtnTypeConfirm,             //确认收货按钮
    CZJOrderListCellBtnTypeCheckCar,            //查看车检情况按钮
    CZJOrderListCellBtnTypeShowBuildingPro,     //查看施工进度按钮
    CZJOrderListCellBtnTypeCancel,              //取消订单按钮
    CZJOrderListCellBtnTypePay,                 //付款按钮
    CZJOrderListCellBtnTypeGoEvaluate,          //去评价按钮
    CZJOrderListCellBtnTypeSelectToPay          //待付款选项选择按钮
};

@protocol CZJOrderListCellDelegate <NSObject>

- (void)clickPaySelectButton:(UIButton*)btn andOrderForm:(CZJOrderListForm*)orderListForm;
- (void)clickOrderListCellAction:(CZJOrderListCellButtonType)buttonType andOrderForm:(CZJOrderListForm*)orderListForm;
@end

@interface CZJOrderListCell : CZJTableViewCell
@property (weak, nonatomic)id <CZJOrderListCellDelegate> delegate;

- (void)setCellModelWithType:(CZJOrderListForm*)listForm andType:(CZJOrderType)orderType;
@end
