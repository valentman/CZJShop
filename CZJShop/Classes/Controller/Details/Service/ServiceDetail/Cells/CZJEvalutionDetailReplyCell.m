//
//  CZJEvalutionDetailReplyCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/31/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJEvalutionDetailReplyCell.h"

@implementation CZJEvalutionDetailReplyCell

- (void)awakeFromNib {
    // Initialization code
    _replyImage.layer.cornerRadius  =20;
    _replyImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
