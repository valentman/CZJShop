//
//  CZJScanRecordMessageCell.h
//  CZJShop
//
//  Created by Joe.Pen on 5/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJScanRecordMessageCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlLabelHeight;
@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
