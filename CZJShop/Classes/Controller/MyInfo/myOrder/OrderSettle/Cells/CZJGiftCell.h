//
//  CZJGiftCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGiftCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *giftItemImg;
@property (weak, nonatomic) IBOutlet UIImageView *giftTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *giftName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftNameHeight;

@end
