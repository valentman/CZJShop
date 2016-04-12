//
//  CZJMessageManager.h
//  CZJShop
//
//  Created by Joe.Pen on 11/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJMessageManager : NSObject
singleton_interface(CZJMessageManager)
@property(nonatomic,retain)NSMutableArray* messages;
@property(nonatomic,assign)BOOL isNewMessage;
-(void)addMessageWithObject:(id)obj;
-(void)removeObjAtIndex:(int)index;
-(void)wirteMessages;
-(void)removeAllMessages;
-(void)readAllMessage;
-(void)readMessageFromPlist;

@end
