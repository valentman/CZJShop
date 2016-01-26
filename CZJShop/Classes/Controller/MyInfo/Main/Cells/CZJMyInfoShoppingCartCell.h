//
//  CZJMyInfoShoppingCartCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMyInfoShoppingCartCellDelegate <NSObject>

- (void)clickMyInfoShoppingCartCell:(id)sender;

@end

@interface CZJMyInfoShoppingCartCell : CZJTableViewCell
@property (weak, nonatomic)id<CZJMyInfoShoppingCartCellDelegate> delegate;
- (IBAction)clickAction:(id)sender;
@end
