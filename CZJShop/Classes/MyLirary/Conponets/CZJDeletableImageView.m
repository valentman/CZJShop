//
//  CZJDeletableImageView.m
//  CZJShop
//
//  Created by Joe.Pen on 2/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJDeletableImageView.h"

@implementation CZJDeletableImageView

- (id)initWithFrame:(CGRect)frame andImageName:(NSString*)imageName
{
    self = [super initWithFrame:frame];
    self.backgroundColor = RGBA(100,100,100,0.6);
    CGSize viewSize = frame.size;
    if (self)
    {
        self.imgName = imageName;
        UIImageView* imageview = [[UIImageView alloc]initWithFrame:frame];
        [imageview setSize:viewSize];
        [imageview setPosition:CGPointZero atAnchorPoint:CGPointZero];
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:DefaultPlaceHolderSquare];
        [self addSubview:imageview];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setSize:CGSizeMake(viewSize.width*0.3, viewSize.height*0.3)];
        [_deleteButton setPosition:CGPointMake(viewSize.width, 0) atAnchorPoint:CGPointMake(1, 0)];
        [_deleteButton setImage:IMAGENAMED(@"commit_icon_del") forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        return self;
    }
    return nil;
}

@end
