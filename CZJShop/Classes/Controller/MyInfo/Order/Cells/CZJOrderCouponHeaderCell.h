//
//  CZJOrderCouponHeaderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/8/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderCouponHeaderCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLayoutWidth;
@property (weak, nonatomic) IBOutlet UIImageView *selfImg;
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;

@end
