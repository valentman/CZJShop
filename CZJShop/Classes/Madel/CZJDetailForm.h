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

    NSMutableArray* _userEvalutionAllForms;         //评价界面全部评价信息列表
    NSMutableArray* _userEvalutionWithPicForms;     //评价界面有图评价信息列表
    NSMutableArray* _userEvalutionGoodForms;        //评价界面好评评价信息列表
    NSMutableArray* _userEvalutionMiddleForms;      //评价界面中评评价信息列表
    NSMutableArray* _userEvalutionBadForms;         //评价界面差评评价信息列表
    
    NSMutableArray* _userEvalutionReplyForms;       //评价回复界面回复信息列表
    
}

@property(nonatomic, strong) NSMutableArray* couponForms;
@property(nonatomic, strong) NSMutableArray* recommendServiceForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionAllForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionWithPicForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionGoodForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionMiddleForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionBadForms;
@property(nonatomic, strong) NSMutableArray* userEvalutionReplyForms;
@property(nonatomic, strong) NSString* purchaseCount;

@end


////---------------------评价详情页评价信息---------------------
@interface CZJEvalutionsForm : NSObject
@property(nonatomic, strong) NSString* evalutionId;
@property(nonatomic, strong) NSMutableArray* imgs;
@property(nonatomic, strong) NSString* replyCount;
@property(nonatomic, strong) NSString* evalStar;
@property(nonatomic, strong) NSString* evalTime;
@property(nonatomic, strong) NSString* evalDesc;
@property(nonatomic, strong) NSString* evalHead;
@property(nonatomic, strong) NSString* evalName;
@property(nonatomic, strong) NSString* purchaseItem;
@property(nonatomic, strong) NSString* purchaseTime;
- (id)initWithDictionary:(NSDictionary*)dict;
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
