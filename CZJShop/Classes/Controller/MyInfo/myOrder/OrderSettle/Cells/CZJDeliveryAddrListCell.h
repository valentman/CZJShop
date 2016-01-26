//
//  CZJDeliveryAddrListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJDeliveryAddrListCellDelegate <NSObject>
- (void)clickEditAddrButton:(id)sender andIndexPath:(NSIndexPath*)indexPath;
- (void)clickDeleteAddrButton:(id)sender andIndexPath:(NSIndexPath*)indexPath;
- (void)clickSetDefault:(id)sender andIndexPath:(NSIndexPath*)indexPath;

@end

@interface CZJDeliveryAddrListCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deliveryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryPhoneNumLable;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddrLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deliveryAddrLayoutWidth;
@property (weak, nonatomic) IBOutlet UIButton *chooseedBtn;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultBtn;
@property (weak, nonatomic)id<CZJDeliveryAddrListCellDelegate> delegate;
@property (strong, nonatomic)NSIndexPath* indexPath;

- (IBAction)deleteAddrAction:(id)sender;
- (IBAction)editAddrAction:(id)sender;
- (IBAction)setDefalutAction:(id)sender;

@end
