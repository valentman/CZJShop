//
//  CZJEvalutionDetailCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJEvalutionDetailCell.h"

@implementation CZJEvalutionDetailCell

- (void)awakeFromNib {
    // Initialization code
    _evalWriteHeadImage.layer.cornerRadius  =20;
    _evalWriteHeadImage.clipsToBounds = YES;
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
