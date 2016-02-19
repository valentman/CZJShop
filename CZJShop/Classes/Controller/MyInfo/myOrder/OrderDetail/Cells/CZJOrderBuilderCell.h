//
//  CZJOrderBuilderCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderBuilderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *builderHeadImg;
@property (weak, nonatomic) IBOutlet UILabel *builderNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *builderNameWidth;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTimeLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *buildingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *builderNameOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTimeOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buildingLabelLeading;

@end
