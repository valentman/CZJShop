//
//  CZJDetailDescCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJDetailDescCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MMLabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goShopImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLayoutConst;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productNameLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originPriceWidth;

@end
