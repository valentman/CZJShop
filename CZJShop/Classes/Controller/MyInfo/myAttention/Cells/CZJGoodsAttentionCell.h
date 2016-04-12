//
//  CZJGoodsAttentionCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGoodsAttentionCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodNameLayoutHeight;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *evaluateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *evaluateLayoutWidth;
@property (weak, nonatomic) IBOutlet UILabel *dealCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dealCountLayoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLayoutLeading;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *goodrateName;
@property (weak, nonatomic) IBOutlet UILabel *dealName;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceButton;
@end
