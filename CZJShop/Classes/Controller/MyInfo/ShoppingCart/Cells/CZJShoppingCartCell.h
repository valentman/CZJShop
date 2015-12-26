//
//  CZJShoppingCartCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJShoppingCartForm.h"


@protocol CZJShoppingCartCellDelegate <NSObject>

- (void)singleClick:(CZJShoppingGoodsInfoForm *)models indexPath:(NSIndexPath*)indexPath;
- (void)changePurchaseNumberNotification;

@end


@interface CZJShoppingCartCell : UITableViewCell

@property(nonatomic,assign)BOOL isEdit;
@property(nonatomic,assign)NSIndexPath* indexPath;
@property(nonatomic,weak)id<CZJShoppingCartCellDelegate> delegate;

- (void)setModels:(CZJShoppingGoodsInfoForm*)shoppingGoodsInfo;

@end
