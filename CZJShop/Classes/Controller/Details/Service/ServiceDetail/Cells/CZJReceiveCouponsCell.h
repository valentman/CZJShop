//
//  CZJReceiveCouponsCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/26/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJReceiveCouponsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *couponPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponPriceLabelLayout;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLabelLayoutheight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLabelLayoutWidth;
@property (weak, nonatomic) IBOutlet UIImageView *receivedImg;
@property (weak, nonatomic) IBOutlet UILabel *receiveTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *couponBgImg;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIView *couponsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponsViewLeadingToSuperView;
@property (weak, nonatomic) IBOutlet UILabel *useableLimitLabel;

- (void)setCellIsTaken:(BOOL)taken andServiceType:(BOOL)isService;
@end
