//
//  CZJRedPacketUseCaseCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJRedPacketUseCaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;

@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;

@property (weak, nonatomic) IBOutlet UILabel *rightItemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBalanceName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBalanceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightNumberLabelWidth;

@property (weak, nonatomic) IBOutlet UILabel *leftBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftItemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftBalanceName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftNumberLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBalanceLabelWidth;



- (void)setRedPacketCellWithData:(id)data;
@end
