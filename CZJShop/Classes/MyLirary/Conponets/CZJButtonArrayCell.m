//
//  CZJButtonArrayCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJButtonArrayCell.h"




@implementation CZJButtonArrayCell
@synthesize buttonDatas = _buttonDatas;
- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _buttonDatas = [NSMutableArray array];
        _currentButtons =[NSMutableArray array];
    }
    return self;
}

-(void)setButtonDatas:(NSArray *)buttonDatas{
    _buttonDatas = [buttonDatas mutableCopy];
    for (int i = 0; i<buttonDatas.count; i++)
    {
        //城市按钮属性设置
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateSelected];
        btn.tag = i;
        [btn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
        btn.layer.borderColor = [RGBA(120, 120, 120, 1) CGColor];
        btn.layer.borderWidth = 0.5;
        btn.layer.cornerRadius = 5.0;
        btn.backgroundColor = [UIColor whiteColor];
        [btn.titleLabel setFont:SYSTEMFONT(12)];
        [self.contentView addSubview:btn];
        [_currentButtons addObject:btn];
    }
}


@end
