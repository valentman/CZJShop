//
//  CZJActivityCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJActivityCell.h"
#import "HomeForm.h"
#import "UIImageView+WebCache.h"
#import "ImagePlayerView.h"

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
    _activeties = array;
    for (ActivityForm* tmp in array) {
        [_imageArray addObject:tmp.img];
    }
    [self loadImageData];
}

- (void)loadImageData{
    self.adScrollView.imagePlayerViewDelegate = self;
    self.adScrollView.scrollInterval = 5.0f;
    self.adScrollView.pageControlPosition = ICPageControlPosition_BottomCenter;
    self.adScrollView.hidePageControl = NO;
    [self.adScrollView reloadData];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return _imageArray.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    [imageView sd_setImageWithURL:[_imageArray objectAtIndex:index] placeholderImage:[UIImage imageNamed:@"default_banner_img.png"]];   
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    ActivityForm* tmp = [_activeties objectAtIndex:index];
    [self.delegate showActivityHtmlWithUrl:tmp.url];
}

@end
