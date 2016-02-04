//
//  CZJOrderPayCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderPayCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
- (IBAction)settleOrderAction:(id)sender;
@end
