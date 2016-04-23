//
//  CZJDetailDescCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailDescCell.h"

@implementation CZJDetailDescCell

- (void)awakeFromNib
{
    _currentPriceLabel.keyWordFont = SYSTEMFONT(15);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
