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
-(void)readMessageFromPlist;
-(void)wirteMessages;

-(void)addMessageWithObject:(id)obj;
-(void)removeObjAtIndex:(int)index;
-(void)removeObjInArray:(NSArray*)removeArray;
-(void)removeAllMessages;
-(void)markReadAllMessage;

-(BOOL)isAllReaded;

@end
