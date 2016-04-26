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
    _imageArray = [array mutableCopy];

    [self loadImageData];
}

- (void)loadImageData{
    self.picDetailView.imagePlayerViewDelegate = self;
    self.picDetailView.autoScroll = NO;
    self.picDetailView.pageControlPosition = ICPageControlPosition_BottomRight;
    self.picDetailView.hidePageControl = NO;
    self.picDetailView.pageControl.pageIndicatorTintColor = CZJNAVIBARBGCOLOR;
    [self.picDetailView reloadData];
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return _imageArray.count == 0 ? 1 : _imageArray.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    __weak typeof(self) weak = self;
    imageView.alpha = 0;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[_imageArray objectAtIndex:index],SUOLUE_PIC_600]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
       [UIView animateWithDuration:1.0 animations:^{
           weak.holderImg.alpha = 0;
           imageView.alpha = 1;
       }];
    }];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    [self.delegate showDetailInfoWithIndex:index];
}

@end
