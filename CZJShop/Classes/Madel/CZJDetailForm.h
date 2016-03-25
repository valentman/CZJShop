//
//  CZJStoreServiceDetailForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJDetailForm : NSObject
{
    NSMutableArray* _recommendServiceForms;         //推荐服务列表
    NSMutableArray* _couponForms;                   //领券列表
    NSMutableArray* _userEvalutionReplyForms;       //评价回复界面回复信息列表
    
}

@property(nonatomic, strong) NSMutableArray* couponForms;
@property(nonatomic, strong) NSMutableArray* recommendServiceForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionReplyForms;
@property(nonatomic, strong) NSString* purchaseCount;

@end


//---------------------评价详情页评价回复信息---------------------
@interface CZJEvalutionReplyForm : NSObject
@property(nonatomic, strong) NSString* replyDesc;
@property(nonatomic, strong) NSString* replyHead;
@property(nonatomic, strong) NSString* replyTime;
@property(nonatomic, strong) NSString* replyId;
@property(nonatomic, strong) NSString* replyName;

- (id)initWithDictionary:(NSDictionary*)dict;
@end
