//
//  CZJChooseTypeHeaderCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/28/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJChooseTypeHeaderCell.h"

@implementation CZJChooseTypeHeaderCell

- (void)awakeFromNib {
    // Initialization code
    _productImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _productImage.layer.borderWidth = 0.5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
