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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)selectAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickToUseRedPacketCallBack:andName:)])
    {
        [self.delegate clickToUseRedPacketCallBack:_selectBtn andName:self.redPacketNameLabel.text];
    }
}
@end
