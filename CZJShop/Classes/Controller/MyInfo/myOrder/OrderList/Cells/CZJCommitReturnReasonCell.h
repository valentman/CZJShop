//
//  CZJCommitReturnReasonCell.h
//  CZJShop
//
//  Created by Joe.Pen on 3/9/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJCommitReturnReasonCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *returnTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *returnTypeBtn;
@property (weak, nonatomic) IBOutlet UIView *picLoadView;
@property (weak, nonatomic) IBOutlet UIButton *picBTn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnTop;

@end
