//
//  CZJStoreInfoHeaerCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJStoreInfoHeaerCell.h"

@implementation CZJStoreInfoHeaerCell

- (void)awakeFromNib {
    // Initialization code
    _attentionStore.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
