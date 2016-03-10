//
//  CZJScanQRController.h
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CZJScanQRController : CZJViewController
@end


@interface CZJSCanQRForm : NSObject
@property (strong, nonatomic) NSString* content;
@property (strong, nonatomic) NSString* isLogin;
@property (strong, nonatomic) NSString* type;
@end