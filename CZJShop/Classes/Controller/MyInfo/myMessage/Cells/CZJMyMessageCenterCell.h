//
//  CZJMyMessageCenterCell.h
//  CZJShop
//
//  Created by Joe.Pen on 5/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMyMessageCenterCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dotLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notifyTimeLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notifyContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameWidth;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@end
