//
//  CZJMiaoShaCollectionCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeForm.h"

@interface CZJMiaoShaCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet MMLabel *originPriceLabel;
@property (weak, nonatomic) IBOutlet MMLabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originPriceLayoutWidth;
@end
