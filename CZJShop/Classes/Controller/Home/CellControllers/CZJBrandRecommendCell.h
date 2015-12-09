//
//  CZJBrandRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CZJBrandRecommendCell : CZJTableViewCell
{
    NSArray* _brandRecommendDatas;
    NSMutableArray* _imageViews;
}
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *towImageView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fourImageView;



- (void)initBrandRecommendWithDatas:(NSArray*)datas;
@end
