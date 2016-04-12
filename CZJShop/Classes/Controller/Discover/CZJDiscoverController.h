//
//  CZJDiscoverViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/1/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CZJDiscoverForm : NSObject
@property(nonatomic, strong) NSString* newsUpdateTime;
@property(nonatomic, strong) NSString* newsBody;

- (instancetype)initWithDictionary:(NSDictionary*)dic;
@end


@interface CZJDiscoverViewController : CZJViewController
@end
