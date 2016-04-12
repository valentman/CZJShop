//
//  CZJLoginController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJLoginController : UIViewController
@property (nonatomic, weak) id <CZJViewControllerDelegate> delegate;

- (IBAction)exitOutAction:(id)sender;
@end
