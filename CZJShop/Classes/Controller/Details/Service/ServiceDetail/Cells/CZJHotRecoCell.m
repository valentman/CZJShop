//
//  CZJHotRecoCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJHotRecoCell.h"

@implementation CZJHotRecoCell

- (void)awakeFromNib {
    // Initialization code
    [_cellBtn addTarget:self action:@selector(btnTouch:) forControlEvents:UIControlEventTouchUpInside];
    _hotRecoImage.layer.borderWidth = 0.5;
    _hotRecoImage.layer.cornerRadius = 2;
    _hotRecoImage.clipsToBounds = YES;
    _hotRecoImage.layer.borderColor = [[UIColor lightGrayColor]CGColor];
}

- (void)btnTouch:(id)sender
{
    
}

@end
