//
//  CZJChatViewCell.h
//  CZJShop
//
//  Created by Joe.Pen on 5/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJChatViewCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLeading;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headPic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
