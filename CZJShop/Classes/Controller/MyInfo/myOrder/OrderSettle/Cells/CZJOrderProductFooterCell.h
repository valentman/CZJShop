//
//  CZJOrderProductFooterCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderProductFooterCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *transportPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transportPriceLayoutWidth;
@end
