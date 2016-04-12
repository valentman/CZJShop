//
//  CZJMessageManager.m
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMessageManager.h"

@implementation CZJMessageManager
singleton_implementation(CZJMessageManager)
- (id) init{
    if (self = [super init]) {
        _messages = [CZJUtils  readArrayFromDocumentsDirectoryWithName:kCZJPlistFileMessage];
        if (!_messages) {
            _isNewMessage = NO;
            _messages = [NSMutableArray array];
        }
        return self;
    }
    
    return nil;
}


-(void)addMessageWithObject:(id)obj{
    if (_messages) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:obj];
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"isRead"];
        [_messages addObject:obj];
        _isNewMessage = YES;
        [self wirteMessages];
    }
}

-(void)readAllMessage{
    if (_messages) {
        for (id dict in _messages) {
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"isRead"];
            [self wirteMessages];
        }
    }
}

-(void)readMessageFromPlist{
    if (_messages) {
        [_messages removeAllObjects];
        _messages = [CZJUtils  readArrayFromDocumentsDirectoryWithName:kCZJPlistFileMessage];
    }
}

-(void)removeObjAtIndex:(int)index{
    if (_messages) {
        [_messages removeObjectAtIndex:index];
    }
}

-(void)wirteMessages{
    if (_messages) {
        [CZJUtils writeArrayToDocumentsDirectory:_messages withPlistName:kCZJPlistFileMessage];
    }
}


-(void)removeAllMessages{
    if (_messages) {
        [_messages removeAllObjects];
        [self wirteMessages];
    }
}
@end
