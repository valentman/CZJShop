//
//  CZJPromotionCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJPromotionCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameTwoLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameOneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameTwoNumLabel;
@end
