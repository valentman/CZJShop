//
//  CZJBrandRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJBrandRecommendCell.h"
#import "HomeForm.h"

@implementation CZJBrandRecommendCell

- (void)awakeFromNib {
    // Initialization code
    _imageViews = [NSMutableArray array];
    [_oneImageView setTag:0];
    [_imageViews addObject:_oneImageView];
    [_towImageView setTag:1];
    [_imageViews addObject:_towImageView];
    [_threeImageView setTag:2];
    [_imageViews addObject:_threeImageView];
    [_fourImageView setTag:3];
    [_imageViews addObject:_fourImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initBrandRecommendWithDatas:(NSArray*)datas
{
    self.isInit = YES;
    _brandRecommendDatas = datas;
    for (int i = 0; i < 4; i++)
    {
        UIImageView* _imageView = (UIImageView*)_imageViews[i];
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:((BrandRecommendForm*)_brandRecommendDatas[i]).img] placeholderImage:DefaultPlaceHolderImage];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)tapGesture
{
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    NSInteger index = imageView.tag;
    [self.delegate showActivityHtmlWithUrl:((BrandRecommendForm*)_brandRecommendDatas[index]).url];
}

@end
