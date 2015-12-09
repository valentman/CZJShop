//
//  CZJAdBanerCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePlayerView.h"

@interface CZJAdBanerCell : UITableViewCell
{
    NSArray* _bannerDatas;
    NSMutableArray* _imageArray;
}
@property (weak, nonatomic) IBOutlet ImagePlayerView *adBannerImageView;

- (void)initBannerOneWithDatas:(NSArray*)datas;
@end
