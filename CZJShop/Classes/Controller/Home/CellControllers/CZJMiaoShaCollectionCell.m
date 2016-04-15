//
//  CZJMiaoShaCollectionCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMiaoShaCollectionCell.h"


@implementation CZJMiaoShaCollectionCell

- (void)awakeFromNib {
    // Initialization code
    self.originPriceLabel.keyWordFont = SYSTEMFONT(12);
    self.currentPriceLabel.keyWordFont = SYSTEMFONT(12);
    self.originPriceLabel.keyWord = @"￥";
    self.currentPriceLabel.keyWord = @"￥";
}

@end
