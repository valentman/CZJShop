//
//  CZJOrderProductHeaderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderProductHeaderCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *needSetupImg;
@property (weak, nonatomic) IBOutlet UILabel *selectedSetupStoreNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImg;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *setupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsNameLayoutWidth;

- (IBAction)clickToChooseSetupPlaceAction:(id)sender;
@end
