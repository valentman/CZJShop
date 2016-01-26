//
//  CZJLeaveMessageCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJLeaveMessageCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIView *leaveMessageView;
@property (weak, nonatomic) IBOutlet UILabel *leaveMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaveMessageLayoutHeight;


@end
