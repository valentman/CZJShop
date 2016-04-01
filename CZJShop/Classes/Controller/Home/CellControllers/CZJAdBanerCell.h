//
//  CZJAdBanerCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePlayerView.h"

@interface CZJAdBanerCell : CZJTableViewCell<ImagePlayerViewDelegate>
{
    NSArray* _bannerDatas;
}
@property (weak, nonatomic) IBOutlet ImagePlayerView *adBannerImageView;
@property (weak, nonatomic) id <CZJImageViewTouchDelegate>delegate;
@property (strong, nonatomic)NSMutableArray* imageArray;

- (void)initBannerOneWithDatas:(NSArray*)datas;
- (void)initBannerWithImg:(NSArray*)img;
@end
