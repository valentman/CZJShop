//
//  StartPageForm.h
//  CheZhiJian
//
//  Created by chelifang on 15/9/6.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartPageForm : NSObject

@property(nonatomic,strong)NSString* startPageTime;
@property(nonatomic,strong)NSString* startPageUrl4S;
@property(nonatomic,strong)NSString* startPageSkip;
@property(nonatomic,strong)NSString* startPageUrl;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
