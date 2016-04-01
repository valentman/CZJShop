//
//  CZJStoreMapCell.h
//  CZJShop
//
//  Created by Joe.Pen on 3/21/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreMapCell : CZJTableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLeading;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeAddrLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLabelHeight;

@property (strong, nonatomic)NSString* storeId;
@end
