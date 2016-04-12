//
//  CZJStoreInfoHeaerCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJStoreInfoHeaerCell.h"

@implementation CZJStoreInfoHeaerCell

- (void)awakeFromNib {
    // Initialization code
    _attentionStore.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_attentionStore setImage:IMAGENAMED(@"prodetail_icon_guanzhu01") forState:UIControlStateNormal];
    [_attentionStore setImage:IMAGENAMED(@"prodetail_icon_guanzhu01_sel") forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)attentionStoreAction:(id)sender {
    [self.delegate clickAttentionStore:self];
}
@end
