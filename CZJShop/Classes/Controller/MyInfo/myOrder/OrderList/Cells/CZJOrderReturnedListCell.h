//
//  CZJOrderReturnedListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/2/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderReturnedListCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *returnBtn;
@property (weak, nonatomic) IBOutlet UIImageView *returnCompleteImg;

@end
