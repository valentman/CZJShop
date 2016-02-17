//
//  CZJRedPacketUseCaseCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJRedPacketUseCaseCell.h"

@interface CZJRedPacketUseCaseCell ()
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UILabel *rightItemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftItemNameLabel;

@end

@implementation CZJRedPacketUseCaseCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRedPacketCellWithData:(id)data
{
    self.rightView.hidden = YES;
}

@end
