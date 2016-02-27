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
    // Initialization code
    [super awakeFromNib];
    stars = [NSArray array];
    stars = @[_starone,_starTwo,_starThr, _starFour,_starFive];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setStar:(int)star
{
    for (int i = 0; i < stars.count; i++)
    {
        if (i == star)
        {
            break;
        }
        UIImageView* image = stars[i];
        [image setHidden:NO];
    }
}

@end
