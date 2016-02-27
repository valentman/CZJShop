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
    [super awakeFromNib];
    _seeAllEvalution.layer.borderWidth = 0.5;
    _seeAllEvalution .layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _seeAllEvalution.layer.cornerRadius = 2;
    
    
    _evalutionReplyBtn.layer.borderWidth = 0.5;
    _evalutionReplyBtn .layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _evalutionReplyBtn.layer.cornerRadius = 2;
    
}   

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)replyEvalutionAction:(id)sender
{
    [self.delegate showDetailInfoWithIndex:[self.form.evalutionId integerValue]];
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

@end
