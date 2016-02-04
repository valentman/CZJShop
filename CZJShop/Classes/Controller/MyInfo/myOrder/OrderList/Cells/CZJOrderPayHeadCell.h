//
//  CZJOrderPayHeadCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderPayHeadCell : UITableViewCell

@property (weak, nonatomic)id <CZJViewControllerDelegate>delegate;
- (IBAction)cancleAction:(id)sender;
@end
