//
//  CZJPicDetailBaseController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJPicDetailBaseController : UIViewController
@property (nonatomic, assign)CZJDetailType detaiViewType;

- (void)loadWebPageWithString:(NSString*)urlString;
@end
