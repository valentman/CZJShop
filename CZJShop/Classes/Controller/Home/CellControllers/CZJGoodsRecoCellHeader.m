//
//  CZJGoodsRecoCellHeader.m
//  CZJShop
//
//  Created by Joe.Pen on 11/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsRecoCellHeader.h"

@implementation CZJGoodsRecoCellHeader
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.viewOneheight.constant = 0.4;
    self.viewTowHeight.constant = 0.4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
