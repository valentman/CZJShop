//
//  CZJMyCarListCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyCarListCell.h"

@implementation CZJMyCarListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteMyCarAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteMyCarActionCallBack:)]) {
        ((UIButton*)sender).tag = self.tag;
        [self.delegate deleteMyCarActionCallBack:sender];
    }
}

- (IBAction)setDefaultAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(setDefaultAcitonCallBack:)])
    {
        ((UIButton*)sender).tag = self.tag;
        [self.delegate setDefaultAcitonCallBack:sender];
    }
}
@end
