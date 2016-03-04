//
//  CZJStoreDetailHeadCell.m
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import "CZJStoreDetailHeadCell.h"

@implementation CZJStoreDetailHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imageArray = [NSMutableArray array];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)someMethodNeedUse:(NSIndexPath *)indexPath DataModel:(NSMutableArray*)array
{
    self.isInit = YES;
    [_imageArray removeAllObjects];
    _imageArray = array;
    
    [self loadImageData];
}

- (IBAction)attentionStoreAction:(id)sender
{
    [self.attentionDelegate clickAttentionButton:self];
}

- (void)loadImageData{
    self.picDetailView.imagePlayerViewDelegate = self;
    self.picDetailView.scrollInterval = 5.0f;
    self.picDetailView.hidePageControl = YES;
    [self.picDetailView reloadData];
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
    [self.delegate showDetailInfoWithIndex:index];
}

@end
