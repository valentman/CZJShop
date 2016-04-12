//
//  CZJOrderListPayCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListPayCell.h"

@implementation CZJOrderListPayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)payAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickToPay:)])
    {
        [self.delegate clickToPay:sender];
    }
}
@end
