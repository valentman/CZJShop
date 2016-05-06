//
//  CZJStartPageForm.m
//  CheZhiJian
//
//  Created by chelifang on 15/9/6.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "CZJStartPageForm.h"

@implementation CZJStartPageForm
@end

@implementation CZJVersionForm
@end

@implementation CZJNotificationForm
- (id)init
{
    if (self = [super init])
    {
        self.isRead = NO;
        self.isSelected = NO;
        self.storeName = @"车之健";
        return self;
    }
    return nil;
}
@end
