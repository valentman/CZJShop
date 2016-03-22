//
//  CZJAdBanerCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePlayerView.h"

@interface CZJAdBanerCell : UITableViewCell<ImagePlayerViewDelegate>
{
    NSArray* _bannerDatas;
    NSMutableArray* _imageArray;
}
@property (weak, nonatomic) IBOutlet ImagePlayerView *adBannerImageView;
@property (weak, nonatomic) id <CZJImageViewTouchDelegate>delegate;

- (void)initBannerOneWithDatas:(NSArray*)datas;
- (void)initBannerWithImg:(NSString*)img;
@end
