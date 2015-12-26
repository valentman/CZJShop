//
//  CZJAdBanerPlusCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJAdBanerPlusCell.h"
#import "HomeForm.h"
#import "UIImageView+WebCache.h"


@implementation CZJAdBanerPlusCell

- (void)awakeFromNib {
    // Initialization code
    _imageArray = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initBannerTwoWithDatas:(NSArray*)datas
{
    _bannerDatas = datas;
    for (BannerForm* tmp in _bannerDatas) {
        [_imageArray addObject:tmp.img];
    }
    [self loadImageData];
}

- (void)loadImageData{
    self.adBannerImageView.imagePlayerViewDelegate = self;
    self.adBannerImageView.scrollInterval = 5.0f;
    self.adBannerImageView.pageControlPosition = ICPageControlPosition_BottomCenter;
    self.adBannerImageView.hidePageControl = NO;
    [self.adBannerImageView reloadData];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return _bannerDatas.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    [imageView sd_setImageWithURL:[_imageArray objectAtIndex:index] placeholderImage:[UIImage imageNamed:@"default_banner_img.png"]];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    NSLog(@"did tap index = %d", (int)index);
    ActivityForm* tmp = [_bannerDatas objectAtIndex:index];
    //    [self.delegate showActivityHtmlWithUrl:tmp.url];
}
@end
