//
//  CZJGoodsRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJGoodsRecommendCellDelegate <NSObject>

@optional
- (void)clickRecommendCellWithID:(NSString*)itemID;
- (void)clickRecommendCellWithID:(NSString*)itemID andPromotionType:(CZJGoodsPromotionType)promotionType;

@end

@interface CZJGoodsRecommendCell : CZJTableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIView *viewTow;
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodNameLabelHeight;
@property (weak, nonatomic) IBOutlet MMLabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodPriceWidth;
@property (weak, nonatomic) IBOutlet MMLabel *goodOriginPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodOriginPriceWidth;

@property (weak, nonatomic) IBOutlet UIImageView *goodImg2;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodNameLabelheight2;
@property (weak, nonatomic) IBOutlet MMLabel *goodPriceLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodPriceWidth2;
@property (weak, nonatomic) IBOutlet MMLabel *goodOriginPriceLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodOriginPriceWidth2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageOneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTwoHeight;
@property (weak, nonatomic) id<CZJGoodsRecommendCellDelegate> delegate;

- (void)initGoodsRecommendWithDatas:(NSArray*)datas;
- (void)initGoodsRecommendWithDatas:(NSArray*)datas andPromotionType:(CZJGoodsPromotionType)promotionType;
@end
