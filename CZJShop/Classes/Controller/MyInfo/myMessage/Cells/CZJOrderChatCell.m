//
//  CZJOrderChatCell.m
//  CZJShop
//
//  Created by Joe.Pen on 5/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderChatCell.h"
#import "EaseBubbleView+Order.h"
@interface CZJOrderChatCell()
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;
@end

@implementation CZJOrderChatCell

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
    NSDictionary* extentsionDic = model.message.ext;
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
    self.bubbleView.orderView.backgroundColor = CLEARCOLOR;
    self.bubbleView.orderView.orderNoLabel.textColor = WHITECOLOR;
    self.bubbleView.orderView.orderMoneyNumLabel.textColor = WHITECOLOR;
    self.bubbleView.orderView.orderTimerLabel.textColor = WHITECOLOR;
    self.bubbleView.orderView.orderMoneyTitle.textColor = RGB(153, 219, 255);
    self.bubbleView.orderView.orderNoTitle.textColor = RGB(153, 219, 255);
    self.bubbleView.orderView.orderTimeTitle.textColor = RGB(153, 219, 255);
    self.bubbleView.orderView.orderNoLabel.font = SYSTEMFONT(14);
    self.bubbleView.orderView.orderMoneyNumLabel.font = SYSTEMFONT(14);
    self.bubbleView.orderView.orderTimerLabel.font = SYSTEMFONT(14);
//    self.bubbleView.orderView.orderMoneyTitle.font = SYSTEMFONT(14);
//    self.bubbleView.orderView.orderNoTitle.font = SYSTEMFONT(14);
//    self.bubbleView.orderView.orderTimeTitle.font = SYSTEMFONT(14);
    
    self.bubbleView.orderView.imageLeading.constant = 0;
    self.bubbleView.orderView.imgeWidth.constant = 0;
    self.bubbleView.orderView.orderNoLeading.constant = 0;
    self.bubbleView.orderView.orderNoLabel.text = [[extentsionDic valueForKey:@"info"] valueForKey:@"orderNo"];
    
    self.bubbleView.orderView.orderMoneyNumLabel.text = [NSString stringWithFormat:@"￥%@",[[extentsionDic valueForKey:@"info"] valueForKey:@"orderPrice"]];
    self.bubbleView.orderView.orderTimerLabel.text = [[extentsionDic valueForKey:@"info"] valueForKey:@"createTime"];
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [self.bubbleView setupOrderBubbleView];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [self.bubbleView updateOrderMargin:bubbleMargin];
}


+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendOrder":@"EaseMessageCellRecvOrder";
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    CGFloat height = 70;
    height += - EaseMessageCellPadding + [EaseMessageCell cellHeightWithModel:model];
    return height;
}
@end
