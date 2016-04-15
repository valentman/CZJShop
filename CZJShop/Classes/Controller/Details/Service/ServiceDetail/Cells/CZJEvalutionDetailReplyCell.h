//
//  CZJEvalutionDetailReplyCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/31/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJEvalutionDetailReplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyContentLayoutHeight;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end
