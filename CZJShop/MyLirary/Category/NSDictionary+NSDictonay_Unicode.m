//
//  NSDictionary+NSDictonay_Unicode.m
//  CheZhiJian
//
//  Created by Joe.Pen on 11/6/15.
//  Copyright © 2015 chelifang. All rights reserved.
//

#import "NSDictionary+NSDictonay_Unicode.h"

@implementation NSDictionary (NSDictonay_Unicode)
- (NSString*)my_description {
    
    NSString *desc = [self my_description];
    
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    
    return desc;
    
}

@end
