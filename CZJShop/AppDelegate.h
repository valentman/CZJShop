//
//  AppDelegate.h
//  CZJShop
//
//  Created by Joe.Pen on 11/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iConsole.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,iConsoleDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end

