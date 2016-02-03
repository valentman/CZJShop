//
//  CZJOrderDetailCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *stageLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stageLabelWidth;


- (void)setOrderStateLayout:(NSInteger)state type:(NSInteger)type;
@end
