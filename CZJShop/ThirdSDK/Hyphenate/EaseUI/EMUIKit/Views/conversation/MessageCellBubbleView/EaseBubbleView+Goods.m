//
//  EaseBubbleView+Goods.m
//  CZJShop
//
//  Created by Joe.Pen on 5/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "EaseBubbleView+Goods.h"

@implementation EaseBubbleView (Goods)

#pragma mark - private

- (void)_setupGoodsBubbleMarginConstraints
{
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.goodsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.goodsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.goodsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.goodsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];

    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupGoodsBubbleConstraints
{
    [self _setupGoodsBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupGoodsBubbleView
{
    self.goodsView = [CZJUtils getXibViewByName:@"CZJScanRecordMessageCell"];
    self.goodsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImageView addSubview:self.goodsView];
    
    [self _setupGoodsBubbleConstraints];
}

- (void)updateGoodsMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupGoodsBubbleConstraints];
}
@end
