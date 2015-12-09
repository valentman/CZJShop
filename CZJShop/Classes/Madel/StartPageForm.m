//
//  StartPageForm.m
//  CheZhiJian
//
//  Created by chelifang on 15/9/6.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "StartPageForm.h"

@implementation StartPageForm

-(id)initWithDictionary:(NSDictionary*)dictionary{
    
    if (self = [super init]) {
        self.startPageTime = [dictionary valueForKey:@"startPageTime"];
        self.startPageUrl4S = [dictionary valueForKey:@"startPageUrl4S"];
        self.startPageSkip = [dictionary valueForKey:@"startPageSkip"];
        self.startPageUrl = [dictionary valueForKey:@"startPageUrl"];
        return self;
    }
    
    return nil;
}

@end
