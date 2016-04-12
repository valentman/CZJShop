//
//  CZJOrderTypeCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderTypeCell.h"

@implementation CZJOrderTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_selectedBtn setImage:[UIImage imageNamed:@"commit_btn_circle_sel"] forState:UIControlStateSelected];
    [_selectedBtn setImage:IMAGENAMED(@"commit_btn_circle") forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrderTypeForm:(CZJOrderTypeForm *)orderTypeForm
{
    self.orderTypeNameLabel.text = orderTypeForm.orderTypeName;
    [self.orderTypeImage setImage:IMAGENAMED(orderTypeForm.orderTypeImg)];
    self.selectedBtn.selected = orderTypeForm.isSelect;
}

@end
