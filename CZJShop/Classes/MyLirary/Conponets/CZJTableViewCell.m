//
//  CZJTableView.m
//  CZJShop
//
//  Created by Joe.Pen on 11/30/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJTableViewCell.h"

@implementation CZJTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //分割线
    CGRect cellRect = self.frame;
    _separatorView = [[UIView alloc]init];
    _separatorView.backgroundColor = CZJGRAYCOLOR;
    _separatorView.frame = CGRectMake(0, cellRect.size.height, PJ_SCREEN_WIDTH, 0.5);
    [self addSubview:_separatorView];
    _separatorView.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setSeparatorViewHidden:(BOOL)_hidden
{
    _separatorView.hidden = _hidden;
    if (!_hidden)
    {//需要显示自定义分割线时，就隐藏系统分割线
        self.separatorInset = HiddenCellSeparator;
    }
}

@end
