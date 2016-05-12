//
//  CZJChatViewButtomView.m
//  CZJShop
//
//  Created by Joe.Pen on 5/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChatViewButtomView.h"

@implementation CZJChatViewButtomView

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)takePicAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(takePicAction:)]){
        [_delegate takePicAction:self];
    }
}

- (IBAction)photoAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(photoAction:)]) {
        [_delegate photoAction:self];
    }
}

- (IBAction)scanRecordAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(scanRecordAction:)]) {
        [_delegate scanRecordAction:self];
    }
}

- (IBAction)myOrderAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(myOrderAction:)]) {
        [_delegate myOrderAction:self];
    }
}

- (IBAction)emotionAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(emotionAction:)]) {
        [_delegate emotionAction:self];
    }
}

@end
