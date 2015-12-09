//
//  CommonUnit.h
//  CheZhiJian
//
//  Created by chelifang on 15/9/5.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUnit : NSObject

+ (CommonUnit *)shareCommonUnit;
- (void)showExitAlertViewWithContent;
- (void)showAlertViewWithContent:(NSString*)content;
@end
