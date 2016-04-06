//
//  CZJAdBanerCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJAdBanerCell.h"
#import "HomeForm.h"

@implementation CZJAdBanerCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _imageArray = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initBannerOneWithDatas:(NSArray*)datas
{
    _bannerDatas = datas;
    [_imageArray removeAllObjects];
    for (BannerForm* tmp in _bannerDatas) {
        [_imageArray addObject:tmp.img];
    }
    [self loadImageData];
}

- (void)initBannerWithImg:(NSArray*)img
{
    [_imageArray removeAllObjects];
    _imageArray = [img mutableCopy];
    [self loadImageData];
    self.adBannerImageView.hidePageControl = YES;
}

- (void)loadImageData{
    self.adBannerImageView.imagePlayerViewDelegate = self;
    self.adBannerImageView.scrollInterval = 6.5f;
    self.adBannerImageView.pageControlPosition = ICPageControlPosition_BottomCenter;
    self.adBannerImageView.hidePageControl = _imageArray.count <= 1;
    [self.adBannerImageView reloadData];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return _imageArray.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    [imageView sd_setImageWithURL:[_imageArray objectAtIndex:index] placeholderImage:DefaultPlaceHolderImage];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    NSLog(@"did tap index = %d", (int)index);
    ActivityForm* tmp = [_bannerDatas objectAtIndex:index];
    [self.delegate showActivityHtmlWithUrl:tmp.url];
    if (self.buttonClick)
    {
        self.buttonClick(@(index));
    }
}

@end
