//
//  CZJMyWalletCardItemCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/18/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyWalletCardItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemNamelabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dotLabel;

@end
