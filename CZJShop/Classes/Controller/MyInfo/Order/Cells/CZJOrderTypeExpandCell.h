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
- (IBAction)clickAction:(id)sender;

@end
