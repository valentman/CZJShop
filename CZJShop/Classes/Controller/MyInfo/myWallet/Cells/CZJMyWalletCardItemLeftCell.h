//
//  CZJMyWalletCardItemLeftCell.h
//  CZJShop
//
//  Created by Joe.Pen on 4/18/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyWalletCardItemLeftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dotLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemNameLabelWidth;

@end
