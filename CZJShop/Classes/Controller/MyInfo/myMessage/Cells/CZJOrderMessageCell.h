//
//  CZJOrderMessageCell.h
//  CZJShop
//
//  Created by Joe.Pen on 5/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderMessageCell : CZJTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *orderNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderMoneyNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderNoLeading;
@end
