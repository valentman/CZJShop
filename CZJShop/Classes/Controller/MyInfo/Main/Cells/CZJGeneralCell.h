//
//  CZJGeneralCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGeneralCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidth;
@property (strong, nonatomic)id tempData;
@end
