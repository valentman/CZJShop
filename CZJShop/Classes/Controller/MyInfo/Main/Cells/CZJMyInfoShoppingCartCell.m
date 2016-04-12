//
//  CZJMyInfoShoppingCartCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoShoppingCartCell.h"

@interface CZJMyInfoShoppingCartCell ()

@end

@implementation CZJMyInfoShoppingCartCell

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
    [self.delegate clickMyInfoShoppingCartCell:sender];
}
@end
