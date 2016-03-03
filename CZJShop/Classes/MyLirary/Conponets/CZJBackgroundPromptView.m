//
//  CZJBackgroundPromptView.m
//  CZJShop
//
//  Created by Joe.Pen on 3/2/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJBackgroundPromptView.h"

@implementation CZJBackgroundPromptView

- (void)awakeFromNib {
    // Initialization code
    [self.promptImageView setImage:IMAGENAMED(@"placeholder_instagram")];
    self.promptLabel.text = @"该店无商品或服务";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
