//
//  CZJStoreServiceCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreServiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *serviceItemName;
@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *originPrice;
@property (weak, nonatomic) IBOutlet UIImageView *serviceTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *purchasedCount;

@end
