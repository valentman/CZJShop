//
//  CZJDeliveryAddrListCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJDeliveryAddrListCell.h"

@implementation CZJDeliveryAddrListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_chooseedBtn setImage:[UIImage imageNamed:@"add_icon_gou"] forState:UIControlStateSelected];
    [_chooseedBtn setImage:nil forState:UIControlStateNormal];
    [_setDefaultBtn setImage:[UIImage imageNamed:@"commit_btn_circle_sel"] forState:UIControlStateSelected];
    [_setDefaultBtn setImage:[UIImage imageNamed:@"commit_btn_circle"] forState:UIControlStateNormal];
    _setDefaultBtn.selected = NO;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteAddrAction:(id)sender {
    [self.delegate clickDeleteAddrButton:sender andIndexPath:self.indexPath];
}

- (IBAction)editAddrAction:(id)sender {
    [self.delegate clickEditAddrButton: sender andIndexPath:self.indexPath];
}

- (IBAction)setDefalutAction:(id)sender {
    _setDefaultBtn.selected = !_setDefaultBtn.selected;
    [self.delegate clickSetDefault:sender andIndexPath:self.indexPath];
}
@end
