//
//  WLZ_ChangeCountView.m
//  WLZ_ShoppingCart
//
//  Created by lijiarui on 15/12/14.
//  Copyright © 2015年 lijiarui. All rights reserved.
//

#import "WLZ_ChangeCountView.h"
#import "UIColor+WLZ_HexRGB.h"
@implementation WLZ_ChangeCountView


- (instancetype)initWithFrame:(CGRect)frame chooseCount:(NSInteger)chooseCount totalCount:(NSInteger)totalCount
{
    self = [super initWithFrame:frame];
    _selfBounds = frame;
    if (self) {
        self.choosedCount = chooseCount;
        self.totalCount = totalCount;
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    _subButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _subButton.frame = CGRectMake(0, 0, _selfBounds.size.height, _selfBounds.size.height);
    _subButton.layer.borderWidth = 1;
    _subButton.layer.borderColor = [[UIColor colorFromHexRGB:@"dddddd"] CGColor];
    _subButton.titleLabel.text = @"-";
    _subButton.titleLabel.textColor = [UIColor lightGrayColor];
    _subButton.titleLabel.font = SYSTEMFONT(15);
    _subButton.exclusiveTouch = YES;
    [self addSubview:_subButton];
    if (self.choosedCount <= 1) {
        _subButton.enabled = NO;
        _subButton.titleLabel.alpha = 0.5f;
    }else{
        _subButton.enabled = YES;
        _subButton.titleLabel.alpha = 1.0f;
    }
    _subButton.backgroundColor=[UIColor whiteColor];
    
    
    _numberFD = [[UITextField alloc]initWithFrame:CGRectMake(_selfBounds.size.height - 1, 0, _selfBounds.size.width - 2 * _selfBounds.size.height + 2, _subButton.frame.size.height)];
    _numberFD.textAlignment=NSTextAlignmentCenter;
    _numberFD.keyboardType=UIKeyboardTypeNumberPad;
    _numberFD.clipsToBounds = YES;
    _numberFD.layer.borderColor = [[UIColor colorFromHexRGB:@"dddddd"] CGColor];
    _numberFD.layer.borderWidth = 1.0;
    _numberFD.textColor = [UIColor colorFromHexRGB:@"333333"];
    _numberFD.font=[UIFont systemFontOfSize:13];
    _numberFD.backgroundColor = [UIColor whiteColor];
    _numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    _numberFD.enabled = NO;
    [self addSubview:_numberFD];
    
    
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(_selfBounds.size.width - _selfBounds.size.height, 0, _selfBounds.size.height, _selfBounds.size.height);
    _addButton.layer.borderWidth = 1;
    _addButton.layer.borderColor = [[UIColor colorFromHexRGB:@"dddddd"] CGColor];
    _addButton.titleLabel.text = @"+";
    _addButton.titleLabel.textColor = [UIColor lightGrayColor];
    _addButton.titleLabel.font = SYSTEMFONT(15);
    _addButton.exclusiveTouch = YES;
    [self addSubview:_addButton];
    if (self.choosedCount >= self.totalCount) {
        _addButton.enabled = NO;
        _addButton.titleLabel.alpha = 0.5f;
    }else{
        _addButton.enabled = YES;
        _addButton.titleLabel.alpha = 1.0f;
    }
    _addButton.backgroundColor=[UIColor whiteColor];
}

@end
