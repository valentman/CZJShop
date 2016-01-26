//
//  CZJOrderListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
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

@interface CZJOrderListCell : CZJTableViewCell


- (void)setCellModelWithType:(CZJOrderType)type;
@end
