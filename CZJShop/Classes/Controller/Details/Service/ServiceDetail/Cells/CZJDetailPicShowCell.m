//
//  CZJDetailPicShowCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailPicShowCell.h"
#import "ImagePlayerView.h"

@implementation CZJDetailPicShowCell

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
    _imageArray = array;

    [self loadImageData];
}

- (void)loadImageData{
    self.picDetailView.imagePlayerViewDelegate = self;
    self.picDetailView.scrollInterval = 5.0f;
    self.picDetailView.pageControlPosition = ICPageControlPosition_BottomCenter;
    self.picDetailView.hidePageControl = NO;
    [self.picDetailView reloadData];
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
    [self.delegate showDetailInfoWithIndex:index];
}

@end
