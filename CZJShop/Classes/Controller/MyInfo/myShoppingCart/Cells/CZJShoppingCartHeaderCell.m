//
//  CZJShoppingCartHeaderCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJShoppingCartHeaderCell.h"

@interface CZJShoppingCartHeaderCell ()
@property (weak, nonatomic) IBOutlet UIButton *allChooseBtn;
@property (weak, nonatomic) IBOutlet UIImageView *storeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *getCouponsBtn;
@property (weak, nonatomic) CZJShoppingCartInfoForm *shoppingCartInfo;
- (IBAction)getCouponsAction:(id)sender;
- (IBAction)allChooseAction:(id)sender;

@end

@implementation CZJShoppingCartHeaderCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}


- (void)setModels:(CZJShoppingCartInfoForm*)shoppingCartInfo
{
    _allChooseBtn.selected = shoppingCartInfo.isSelect;
    _storeTypeImage.highlighted = !shoppingCartInfo.selfFlag;
    _storeNameLabel.text = shoppingCartInfo.storeName;
    _getCouponsBtn.hidden = !shoppingCartInfo.hasCoupon;
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle.png") forState:UIControlStateNormal];
    [_allChooseBtn setImage:IMAGENAMED(@"commit_btn_circle_sel.png") forState:UIControlStateSelected];
}

- (IBAction)getCouponsAction:(id)sender
{
    [self.delegate clickGetCoupon:sender andIndexPath:self.indexPath];
}

- (IBAction)allChooseAction:(id)sender
{
//    _allChooseBtn.selected = !_allChooseBtn.selected;
    
    if ([self.delegate respondsToSelector:@selector(clickChooseAllSection:andIndexPath:)])
    {
        [self.delegate clickChooseAllSection:_allChooseBtn andIndexPath:self.indexPath];
    }
}




@end
