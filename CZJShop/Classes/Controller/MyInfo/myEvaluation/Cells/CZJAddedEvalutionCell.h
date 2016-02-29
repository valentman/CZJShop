//
//  CZJAddedEvalutionCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/27/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJAddedEvalutionCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedContentLabel;
@property (weak, nonatomic) IBOutlet UIView *picView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeight;

@end
