//
//  CZJGoodsListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGoodsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodPrice;
@property (weak, nonatomic) IBOutlet UILabel *goodRate;
@property (weak, nonatomic) IBOutlet UILabel *puchaseCount;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UIImageView *imageOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *purchaseCountWidth;
@property (weak, nonatomic) IBOutlet UILabel *goodRateName;
@property (weak, nonatomic) IBOutlet UILabel *dealName;

@end
