//
//  CZJButton.m
//  CZJShop
//
//  Created by Joe.Pen on 12/12/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJButton.h"
@interface CZJButton()
@property (strong, nonatomic)UILabel* badgeLabel;

@end

@implementation CZJButton

- (void)setBadgeNum:(NSInteger)badgeNum
{
    if (0 == badgeNum)
    {
        return;
    }
    if (!VIEWWITHTAG(self, 99))
    {
        _badgeLabel = [[UILabel alloc]init];
        _badgeLabel.hidden = YES;
        _badgeLabel.layer.backgroundColor = CZJREDCOLOR.CGColor;
        [_badgeLabel setTag:99];
        [self addSubview:_badgeLabel];
        
        CGRect labelRect;
        if (-1 == badgeNum)
        {
            labelRect = CGRectMake(self.bounds.size.width - 5, 5, 5, 5);
            _badgeLabel.layer.cornerRadius = 2.5;
        }
        else
        {
            NSString* badgeStr = [NSString stringWithFormat:@"%ld", badgeNum];
            CGSize labelSize = [CZJUtils calculateTitleSizeWithString:badgeStr AndFontSize:10];
            [_badgeLabel setSize:CGSizeMake(labelSize.width < 15 ? 15 : labelSize.width, 15)];
            _badgeLabel.text = badgeStr;
            _badgeLabel.textColor = [UIColor whiteColor];
            _badgeLabel.textAlignment = NSTextAlignmentCenter;
            _badgeLabel.font = SYSTEMFONT(10);
            _badgeLabel.layer.cornerRadius = 7.5;
        }
        [self setBadgeLabelPosition:CGPointMake(self.bounds.size.width, 0)];
        _badgeLabel.hidden = NO;
    }
}

- (void)setBadgeLabelPosition:(CGPoint)pt
{
    [_badgeLabel setPosition:pt atAnchorPoint:CGPointTopRight];
}

@end
