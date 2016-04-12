//
//  CZJStoreAttentionHeadCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreAttentionHeadCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *storeImg;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attentionCountLayoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLayoutLeading;

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@end
