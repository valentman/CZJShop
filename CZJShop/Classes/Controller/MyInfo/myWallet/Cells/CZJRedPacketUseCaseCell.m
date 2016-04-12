//
//  CZJRedPacketUseCaseCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJRedPacketUseCaseCell.h"

@interface CZJRedPacketUseCaseCell ()


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
