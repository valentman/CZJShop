//
//  CZJChooseTypeHeaderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/28/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJChooseTypeHeaderCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productNameLabelLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productNameLabelLayoutWidth;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productPriceLabelLayoutWidth;
@property (weak, nonatomic) IBOutlet UILabel *productCodeLabel;

@end
