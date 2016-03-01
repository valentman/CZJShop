//
//  CZJGoodsRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJGoodsRecommendCellDelegate <NSObject>

- (void)clickRecommendCellWithID:(NSString*)itemID;

@end

@interface CZJGoodsRecommendCell : CZJTableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIView *viewTow;
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodImg2;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageOneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTwoHeight;
@property (weak, nonatomic) id<CZJGoodsRecommendCellDelegate> delegate;

- (void)initGoodsRecommendWithDatas:(NSArray*)datas;
@end
