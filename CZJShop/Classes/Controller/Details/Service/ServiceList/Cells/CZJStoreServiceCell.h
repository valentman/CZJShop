//
//  CZJStoreServiceCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreServiceCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *serviceItemName;
@property (weak, nonatomic) IBOutlet MMLabel *currentPrice;
@property (weak, nonatomic) IBOutlet UIImageView *serviceTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *purchasedCount;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *goodRate;
@property (weak, nonatomic) IBOutlet UIImageView *serviceImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *purchasedCountWidth;
@property (weak, nonatomic) IBOutlet UIImageView *imageOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageTwo;

@end
