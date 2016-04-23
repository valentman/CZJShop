//
//  CZJGoodsListCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsListCell.h"

@implementation CZJGoodsListCell

- (void)awakeFromNib {
    // Initialization code
    self.goodPrice.keyWordFont = SYSTEMFONT(12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
