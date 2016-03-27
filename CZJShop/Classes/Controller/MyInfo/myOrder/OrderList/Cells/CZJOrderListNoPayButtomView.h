//
//  CZJOrderListNoPayButtomView.h
//  CZJShop
//
//  Created by Joe.Pen on 2/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderListNoPayButtomView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *allChooseBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToPayBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goToPayWidth;

@end
