//
//  CZJOrderTypeExpandCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderTypeExpandCell.h"

@implementation CZJOrderTypeExpandCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickAction:(id)sender
{
    [self.delegate clickToExpandOrderType];
}
@end
