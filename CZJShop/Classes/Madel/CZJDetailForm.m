//
//  CZJStoreServiceDetailForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDetailForm.h"
#import "CZJStoreForm.h"

@implementation CZJDetailForm
- (id)init
{
    if (self = [super init])
    {
        _recommendServiceForms = [NSMutableArray array];
        _couponForms = [NSMutableArray array];
        _userEvalutionReplyForms = [NSMutableArray array];
        return self;
    }
    return nil;
}
@end

@implementation CZJEvalutionReplyForm
@synthesize replyDesc = _replyDesc;
@synthesize replyHead = _replyHead;
@synthesize replyTime = _replyTime;
@synthesize replyId = _replyId;
@synthesize replyName = _replyName;


- (id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.replyDesc = [dict valueForKey:@"replyDesc"];
        self.replyHead = [dict valueForKey:@"replyHead"];
        self.replyTime = [dict valueForKey:@"replyTime"];
        self.replyId = [dict valueForKey:@"replyId"];
        self.replyName = [dict valueForKey:@"replyName"];
        return self;
    }
    return nil;
}

@end