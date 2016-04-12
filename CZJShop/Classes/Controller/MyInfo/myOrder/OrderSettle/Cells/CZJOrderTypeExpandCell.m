//
//  CZJOrderTypeExpandCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderTypeExpandCell.h"

@implementation CZJOrderTypeExpandCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellType:(CZJCellType)cellType
{
    if (CZJCellTypeDetail == cellType)
    {
        self.detailImg.transform = CGAffineTransformMakeRotation(180*M_PI/180);
        self.detailImg.hidden = NO;
        self.detailNameLabel.hidden = NO;
        self.expandImg.hidden = YES;
        self.expandNameLabel.hidden = YES;
    }
    if (CZJCellTypeExpand == cellType)
    {
        self.detailImg.hidden = YES;
        self.detailNameLabel.hidden = YES;
        self.expandImg.hidden = NO;
        self.expandNameLabel.hidden = NO;
    }
}

- (IBAction)clickAction:(id)sender
{
    [self.delegate clickToExpandOrderType];
    if (self.buttonClick)
    {
        self.buttonClick(nil);
    }
}
@end
