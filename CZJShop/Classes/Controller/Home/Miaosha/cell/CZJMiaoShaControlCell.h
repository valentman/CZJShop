//
//  CZJMiaoShaControlCell.h
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMiaoShaControlCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodName;
@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *originPrice;
@property (weak, nonatomic) IBOutlet UILabel *leftNum;
@property (weak, nonatomic) IBOutlet UIView *alreadyOverView;
@property (weak, nonatomic) IBOutlet UIView *goingOnView;

@property (weak, nonatomic) IBOutlet UIButton *alreadyOverBtn;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UIButton *alreadyBuyBtn;
@property (weak, nonatomic) IBOutlet UIButton *goBuyBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodNameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentPriceWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originPriceWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftNumWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundLabelTrailing;


- (IBAction)goBuyAction:(id)sender;
@end
