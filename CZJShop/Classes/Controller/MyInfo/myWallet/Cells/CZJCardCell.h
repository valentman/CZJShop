//
//  CZJCardCell.h
//  CZJShop
//
//  Created by Joe.Pen on 5/20/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJCardCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *vipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *storeImg;
@property (weak, nonatomic) IBOutlet MMLabel *memberNumLabel;
@property (weak, nonatomic) IBOutlet MMLabel *currentPoint;
@property (weak, nonatomic) IBOutlet MMLabel *allPoint;
@property (weak, nonatomic) IBOutlet UIView *memverCardView;
@property (weak, nonatomic) IBOutlet UIView *pointCardView;

@end
