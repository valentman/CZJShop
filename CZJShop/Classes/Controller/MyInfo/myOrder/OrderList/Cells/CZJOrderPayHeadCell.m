//
//  CZJOrderPayHeadCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderPayHeadCell.h"

@implementation CZJOrderPayHeadCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cancleAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancel:)])
    {
        [self.delegate didCancel:nil];
    }
}
@end
