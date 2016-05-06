//
//  CZJStartPageForm.h
//  CheZhiJian
//
//  Created by chelifang on 15/9/6.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJStartPageForm : NSObject
@property(nonatomic,strong)NSString* startPageTime;
@property(nonatomic,strong)NSString* startPageUrl4S;
@property(nonatomic,assign)BOOL startPageSkip;
@property(nonatomic,strong)NSString* startPageUrl;
@property(nonatomic,strong)NSString* startPageOverdueTime;
@end


@interface CZJVersionForm : NSObject
@property(nonatomic,strong)NSString* enforce;
@property(nonatomic,strong)NSString* url;
@property(nonatomic,strong)NSString* version;
@property(nonatomic,strong)NSString* versionNo;
@end



@interface CZJNotificationForm : NSObject
@property(nonatomic,strong)NSString* type;
@property(nonatomic,strong)NSString* runType;
@property(nonatomic,strong)NSString* msg;
@property(nonatomic,strong)NSString* url;
@property(nonatomic,strong)NSString* time;
@property(nonatomic,strong)NSString* orderNo;
@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)NSString* storeName;
@property(nonatomic,assign)BOOL isRead;
@property(nonatomic,assign)BOOL isSelected;

- (id)init;
@end