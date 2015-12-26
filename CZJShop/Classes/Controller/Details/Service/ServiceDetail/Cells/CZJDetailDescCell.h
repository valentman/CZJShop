//
//  CZJDetailDescCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJDetailDescCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goShopImage;
@property (weak, nonatomic) IBOutlet UILabel *miaoShaLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLayoutConst;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productNameLayoutHeight;

@end
