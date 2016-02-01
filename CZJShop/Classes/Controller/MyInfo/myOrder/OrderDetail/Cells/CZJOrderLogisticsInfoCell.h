//
//  CZJOrderLogisticsInfoCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderLogisticsInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *logisticsStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *logisticsLabel;

@end