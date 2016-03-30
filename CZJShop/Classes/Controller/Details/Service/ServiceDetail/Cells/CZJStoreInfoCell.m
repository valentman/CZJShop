//
//  CZJStoreInfoCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJStoreInfoCell.h"

@implementation CZJStoreInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _contactServerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _intoStoreButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
