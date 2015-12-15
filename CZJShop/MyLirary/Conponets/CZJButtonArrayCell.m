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
        btn.layer.borderColor = [RGBACOLOR(200, 200, 200, 1) CGColor];
        btn.layer.borderWidth = 1.0;
        btn.layer.cornerRadius = 5.0;
        btn.backgroundColor = [UIColor whiteColor];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:btn];
    }
}


//-(void)locationBtnClick:(UIButton *)btn
//{
//    // NSLog(@"定位城市：%@",btn.currentTitle);
//    if ([self.delegate respondsToSelector:@selector(cityTableViewCell:didClickLocationBtnTitle:)]) {
//        [self.delegate cityTableViewCell:self didClickLocationBtnTitle:btn.currentTitle];
//    }
//}
//
//- (void)selectedBtnClick:(UIButton *)btn
//{
//    // NSLog(@"%@",btn.currentTitle);
//    if ([self.delegate respondsToSelector:@selector(cityTableViewCell:didClickBtnTitle:andId:)]) {
//        NSString* cityId = [_buttonDatas[btn.tag] valueForKey:@"cityId"];
//        [self.delegate cityTableViewCell:self didClickBtnTitle:btn.currentTitle andId:cityId];
//    }
//}


@end
