//
//  CZJMiaoShaCollectionCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMiaoShaCollectionCell.h"
#import "UIImageView+WebCache.h"

@implementation CZJMiaoShaCollectionCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)initMiaoShaCollectionCellWithData:(SecSkillsForm*)data
{
    _originPriceLabel.text = data.originalPrice;
    _currentPriceLabel.text = data.currentPrice;
    
    SDWebImageCompletionBlock sdimgBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){};
    [_iconImage sd_setImageWithURL:[NSURL URLWithString:data.img] placeholderImage:[UIImage imageNamed:@"home_btn_xiche"] completed:sdimgBlock];
}

@end
