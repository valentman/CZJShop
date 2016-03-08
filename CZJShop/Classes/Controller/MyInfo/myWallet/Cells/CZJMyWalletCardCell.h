//
//  CZJMyWalletCardCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJMyCardInfoForm.h"
@interface CZJMyWalletCardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemNameLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardTypeWidth;


- (void)setCardCellWithCardDetailInfo:(CZJMyCardInfoForm*)cardInfo;

@end
