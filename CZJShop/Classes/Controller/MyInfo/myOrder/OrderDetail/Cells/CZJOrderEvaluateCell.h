//
//  CZJOrderEvaluateCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderEvaluateCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImg;
@property (strong, nonatomic) IBOutlet CZJStarRageView *starView;
@property (weak, nonatomic) IBOutlet UIButton *picBTn;
@property (weak, nonatomic) IBOutlet UITextView *messageTextField;
@property (weak, nonatomic) IBOutlet UIView *picLoadView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnTop;
@end
