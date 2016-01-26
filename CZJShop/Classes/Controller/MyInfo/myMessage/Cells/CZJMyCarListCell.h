//
//  CZJMyCarListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyCarListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *brandImg;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultBtn;
- (IBAction)deleteMyCarAction:(id)sender;
- (IBAction)setDefaultAction:(id)sender;

@end
