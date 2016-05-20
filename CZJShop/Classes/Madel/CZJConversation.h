//
//  CZJConversation.h
//  CZJShop
//
//  Created by Joe.Pen on 5/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJConversation : NSObject
@property (strong, nonatomic) EMConversation* emConversation;
@property (assign, nonatomic) BOOL isSelected;
@end
