//
//  CZJStoreCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/2/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *storeCellImageView;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *dealCount;
@property (weak, nonatomic) IBOutlet UILabel *storeLocation;
@property (weak, nonatomic) IBOutlet UILabel *storeDistance;
@property (weak, nonatomic) IBOutlet UILabel *feedbackRate;

@end
