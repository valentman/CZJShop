//
//  CZJOrderEvalutateAllCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderEvalutateAllCell.h"

@implementation CZJOrderEvalutateAllCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _descView = [[CZJStarRageView alloc]initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - self.descView.frame.size.width - 15), self.descView.frame.origin.y, self.descView.frame.size.width, self.descView.frame.size.height) starCount:5];
    [self.contentView addSubview:_descView];

    _serviceView = [[CZJStarRageView alloc]initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - self.descView.frame.size.width - 15), self.serviceView.frame.origin.y, self.descView.frame.size.width, self.serviceView.frame.size.height) starCount:5];;
    [self.contentView addSubview:_serviceView];
    
    _evirView = [[CZJStarRageView alloc]initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - self.descView.frame.size.width - 15), self.evirView.frame.origin.y, self.descView.frame.size.width, self.evirView.frame.size.height) starCount:5];
    [self.contentView addSubview:_evirView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
