//
//  CZJOrderLogisticsCompCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderLogisticsCompCell.h"

@implementation CZJOrderLogisticsCompCell

- (void)awakeFromNib {
    self.spatatorWidth.constant = 0.5;
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
