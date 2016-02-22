//
//  CZJOrderTypeExpandCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/7/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJOrderTypeExpandCellDelegate <NSObject>

- (void)clickToExpandOrderType;

@end

@interface CZJOrderTypeExpandCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *expandNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandImg;
@property (weak, nonatomic) id<CZJOrderTypeExpandCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *expandView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImg;
@property (weak, nonatomic) IBOutlet UILabel *detailNameLabel;


- (void)setCellType:(CZJCellType)cellType;
- (IBAction)clickAction:(id)sender;

@end
