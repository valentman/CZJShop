//
//  CZJRedPacketCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJRedPacketCell.h"

@implementation CZJRedPacketCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_selectBtn setImage:[UIImage imageNamed:@"commit_icon_swich_off"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"commit_icon_swich_on"] forState:UIControlStateSelected];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectAction:(id)sender {
    _selectBtn.selected = !_selectBtn.selected;
    if ([self.delegate respondsToSelector:@selector(clickToUseRedPacketCallBack:andName:)])
    {
        [self.delegate clickToUseRedPacketCallBack:_selectBtn andName:self.leftLabel.text];
    }
}
@end
