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
}

- (void)btnTouch:(id)sender
{
    if (self.hotBtnClick)
    {
        self.hotBtnClick(self.hotRecoData);
    }
}

@end
