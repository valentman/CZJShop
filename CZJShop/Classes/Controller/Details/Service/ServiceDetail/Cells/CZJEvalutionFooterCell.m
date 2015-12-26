//
//  CZJEvalutionFooterCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJEvalutionFooterCell.h"

@implementation CZJEvalutionFooterCell

- (void)awakeFromNib {
    // Initialization code
    [self.evalutionReplyBtn addTarget:self action:@selector(goToReplyDetail:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVisibleView:(NSInteger)type
{
    if (kLookAllEvalView == type)
    {
        _allEvalView.hidden = NO;
        _evalDetailView.hidden = YES;
    }
    else if (kEvalDetailView == type)
    {
        _allEvalView.hidden = YES;
        _evalDetailView.hidden = NO;
    }
}

- (void)goToReplyDetail:(id)sender
{
    [self.delegate showDetailInfoWithIndex:self.form.evalutionId];
}

@end
