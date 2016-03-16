//
//  CZJOrderListPayCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJOrderListPayCellDelegate <NSObject>

- (void)clickToPay:(id)sender;

@end

@interface CZJOrderListPayCell : CZJTableViewCell
@property (weak, nonatomic)id<CZJOrderListPayCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *orderMoneyLabel;

- (IBAction)payAction:(id)sender;
@end
