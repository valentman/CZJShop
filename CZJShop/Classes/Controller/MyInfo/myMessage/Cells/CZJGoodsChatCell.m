//
//  CZJGoodsChatCell.m
//  CZJShop
//
//  Created by Joe.Pen on 5/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJGoodsChatCell.h"
#import "EaseBubbleView+Goods.h"
#import "CZJScanRecordMessageCell.h"

@interface CZJGoodsChatCell()
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@end

@implementation CZJGoodsChatCell
+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat margin = [EaseMessageCell appearance].leftBubbleMargin.left + [EaseMessageCell appearance].leftBubbleMargin.right;
    self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:215 + margin];
    
    [self addConstraint:self.bubbleWithImageConstraint];
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    NSDictionary* extDict = model.message.ext;
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
    CZJMyScanRecordForm* goodsForm = [CZJMyScanRecordForm objectWithKeyValues:[extDict valueForKey:@"info"]];
    [self.bubbleView.goodsView.goodImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    
    CGSize goodNameSize = [CZJUtils calculateStringSizeWithString:goodsForm.itemName Font:SYSTEMFONT(14) Width:240-90];
    self.bubbleView.goodsView.goodNameLabel.text = goodsForm.itemName;
    self.bubbleView.goodsView.nameLabelHeight.constant = goodNameSize.height > 20 ? 40 : 20;
    
    self.bubbleView.goodsView.priceLabel.text = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
    
    CGSize urlSize = [CZJUtils calculateStringSizeWithString:goodsForm.itemImg Font:SYSTEMFONT(12) Width:240];
    self.bubbleView.goodsView.urlLabel.text = goodsForm.itemImg;
    self.bubbleView.goodsView.urlLabelHeight.constant = urlSize.height;
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [self.bubbleView setupGoodsBubbleView];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [self.bubbleView updateGoodsMargin:bubbleMargin];
}


+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendGoods":@"EaseMessageCellRecvGoods";
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    CGFloat height = 100;
    height += - EaseMessageCellPadding + [EaseMessageCell cellHeightWithModel:model];
    return height;
}


@end
