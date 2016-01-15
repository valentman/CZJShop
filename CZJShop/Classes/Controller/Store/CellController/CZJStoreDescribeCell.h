//
//  CZJStoreDescribeCell.h
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreDescribeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *envirmentScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryScoreLabel;

@end
