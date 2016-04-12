//
//  CZJMiaoShaControlHeaderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMiaoShaControlHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *miaoShaTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *miaoshaTimeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *miaoshaIconLeading;

@end
