//
//  CZJDeliveryAddrCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"
@interface CZJDeliveryAddrCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deliveryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddrLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deliveryAddrrLayoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deliveryAddrLayoutLeading;
@property (strong, nonatomic) CZJAddrForm* addrForm;
@property (weak, nonatomic) IBOutlet UIImageView *commitNextArrowImg;
@property (weak, nonatomic) IBOutlet UIImageView *deliverLocaitonIMg;
@property (weak, nonatomic) IBOutlet UIImageView *addLineImg;
@end
