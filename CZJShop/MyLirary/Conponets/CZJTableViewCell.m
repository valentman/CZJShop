//
//  CZJTableView.m
//  CZJShop
//
//  Created by Joe.Pen on 11/30/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJTableViewCell.h"

@implementation CZJTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
