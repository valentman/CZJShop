//
//  CZJEvalutionDescCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJEvalutionDescCell.h"

@implementation CZJEvalutionDescCell

- (void)awakeFromNib {
    [super awakeFromNib];
    stars = [NSArray array];
    stars = @[_starone,_starTwo,_starThr, _starFour,_starFive];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)setStar:(int)star
{
    for (int i = 0; i < stars.count; i++)
    {
        UIImageView* image = stars[i];
        [image setImage:IMAGENAMED(@"evaluate_icon_star_white")];
        if (i < star)
        {
            [image setImage:IMAGENAMED(@"evaluate_icon_star_red")];
        }
    }
}

@end
