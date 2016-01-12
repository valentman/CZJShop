//
//  CZJChooseInstallStoreCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChooseInstallStoreCell.h"

@implementation CZJChooseInstallStoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_selectBtn setImage:IMAGENAMED(@"commit_icon_circle2") forState:UIControlStateNormal];
    [_selectBtn setImage:IMAGENAMED(@"commit_icon_circle2_sel") forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
