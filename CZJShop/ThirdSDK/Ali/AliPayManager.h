//
//  AliPayManager.h
//  CheZhiJian
//
//  Created by chelifang on 15/8/8.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliPayManager : NSObject
- (void)generateWithOrderDict:(NSDictionary*)dict
                      Success:(paySuccess)success
                         Fail:(payFail)fail;
@end
