//
//  CZJGoodsRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CZJGoodsRecommendCell : CZJTableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodImg2;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel2;

- (void)initGoodsRecommendWithDatas:(NSArray*)datas;
@end
