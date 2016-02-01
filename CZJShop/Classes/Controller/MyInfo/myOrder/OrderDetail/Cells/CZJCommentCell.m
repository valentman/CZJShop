//
//  CZJCommentCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJCommentCell.h"

@implementation CZJCommentCell

- (void)awakeFromNib {
    // Initialization code
    [CZJUtils creatIndicatorWithColor:[UIColor lightGrayColor] andPosition:CGPointMake(30, 15)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
