//
//  CZJShoppingCartHeaderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJShoppingCartForm.h"


@protocol CZJShoppingCartHeaderCellDelegate <NSObject>
@optional
- (void)clickChooseAllSection:(id)sender andIndexPath:(NSIndexPath*)indexPath;
- (void)clickGetCoupon:(id)sender andIndexPath:(NSIndexPath*)indexPath;

@end

@interface CZJShoppingCartHeaderCell : UITableViewCell
@property(nonatomic,assign)NSIndexPath* indexPath;
@property(weak, nonatomic) id<CZJShoppingCartHeaderCellDelegate>delegate;
- (void)setModels:(CZJShoppingCartInfoForm*)shoppingCartInfo;
@end
