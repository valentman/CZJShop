//
//  CZJLoadingFailedAlertView.h
//  CZJShop
//
//  Created by Joe.Pen on 3/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJLoadingFailedAlertView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (copy, nonatomic) CZJGeneralBlock reloadHandle;
- (void)setRoloadHandle:(CZJGeneralBlock)reloadHandle;
@end
