//
//  CZJGoodsRecoCellHeader.h
//  CZJShop
//
//  Created by Joe.Pen on 11/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGoodsRecoCellHeader : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *recoMenuLabel;
@property (weak, nonatomic) IBOutlet UILabel *recoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recoImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recoViewLayoutWidth;

@end
