//
//  CZJActivityCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJActivityCell.h"
#import "HomeForm.h"


@implementation CZJActivityCell

- (void)awakeFromNib {
    _imageArray = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)someMethodNeedUse:(NSIndexPath *)indexPath DataModel:(NSMutableArray*)array
{
    self.isInit = YES;
    [_imageArray removeAllObjects];
    _activeties = [array mutableCopy];
    for (ActivityForm* tmp in array) {
        [_imageArray addObject:tmp.img];
    }
    [self loadImageData];
}

- (void)loadImageData
{
    if (!_adScrollerView)
    {
        _adScrollerView = [[FZADScrollerView alloc] initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, 210)];
        _adScrollerView.delegate = self;
        [self addSubview:_adScrollerView];
    }
    [_adScrollerView setImages:_imageArray];
}

- (void)didSelectImageAtIndexPath:(NSInteger)indexPath
{
    NSLog(@"didSelectImageIndexPath = %ld", indexPath);
    ActivityForm* tmp = [_activeties objectAtIndex:indexPath];
    [self.delegate showActivityHtmlWithUrl:tmp.url];
}

@end
