//
//  CZJOrderEvaluateCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderEvaluateCell.h"

@implementation CZJOrderEvaluateCell

- (void)awakeFromNib {
    CZJStarRageView* starView = [[CZJStarRageView alloc]initWithFrame:self.starView.frame starCount:5];;
    [self.contentView addSubview:starView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
