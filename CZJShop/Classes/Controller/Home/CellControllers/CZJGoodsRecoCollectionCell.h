//
//  CZJGoodsRecoCollectionCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/26/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGoodsRecoCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet MMLabel *productPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productNameHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageTwo;
@end
