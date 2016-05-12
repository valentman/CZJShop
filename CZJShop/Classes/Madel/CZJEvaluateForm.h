//
//  CZJEvaluateForm.h
//  CZJShop
//
//  Created by Joe.Pen on 2/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CZJAddedMyEvalutionForm;

//--------------------详情页面评价简介信息---------------------
@interface CZJDetailEvalInfo : NSObject
@property(nonatomic, strong) NSString* poorCount;
@property(nonatomic, strong) NSArray* evalList;
@property(nonatomic, strong) NSString* goodCount;
@property(nonatomic, strong) NSString* goodRate;
@property(nonatomic, strong) NSString* evalCount;
@property(nonatomic, strong) NSString* hasImgCount;
@property(nonatomic, strong) NSString* normalCount;
@end

//--------------------详情页面评价简介Item信息---------------------
@interface CZJEvaluateForm : NSObject
@property (nonatomic, strong) NSString* added;
@property (strong, nonatomic) CZJAddedMyEvalutionForm* addedEval;
@property (nonatomic, strong) NSString* chezhuId;
@property (nonatomic, strong) NSString* chezhuMobile;
@property (nonatomic, strong) NSString* counterKey;
@property (nonatomic, strong) NSString* createTime;
@property (nonatomic, strong) NSArray* evalImgs;
@property (nonatomic, strong) NSString* evalLevel;
@property (nonatomic, strong) NSString* evalTime;
@property (strong, nonatomic) NSString* evaluateID;
@property (nonatomic, strong) NSString* hasImg;
@property (nonatomic, strong) NSString* head;
@property (nonatomic, strong) NSString* ID;
@property (nonatomic, strong) NSString* itemImg;
@property (nonatomic, strong) NSString* itemName;
@property (nonatomic, strong) NSString* itemSku;
@property (nonatomic, strong) NSString* itemType;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* orderNo;
@property (nonatomic, strong) NSString* orderTime;
@property (nonatomic, strong) NSString* replyCount;
@property (nonatomic, strong) NSString* score;
@property (nonatomic, strong) NSString* storeId;
@property (nonatomic, strong) NSString* storeItemPid;
@end

//---------------------评价详情页评价回复信息---------------------
@interface CZJEvalutionReplyForm : NSObject
@property(nonatomic, strong) NSString* replyDesc;
@property(nonatomic, strong) NSString* replyHead;
@property(nonatomic, strong) NSString* replyTime;
@property(nonatomic, strong) NSString* replyId;
@property(nonatomic, strong) NSString* replyName;
@end

//--------------------我的评价简介Item信息---------------------
@interface CZJMyEvaluationForm : NSObject
@property (strong, nonatomic)NSString*  activityId;
@property (strong, nonatomic)NSString* orderNo;
@property (strong, nonatomic)NSString* serviceScore;
@property (strong, nonatomic)NSString* descScore;
@property (strong, nonatomic)NSString* environmentScore;
@property (strong, nonatomic)NSString* deliveryScore;
@property (strong, nonatomic)NSString* storeId;
@property (strong, nonatomic)NSString* head;
@property (strong, nonatomic)NSString* name;
@property (strong, nonatomic)NSString* orderTime;
@property (strong, nonatomic)NSMutableArray* items;
@end


//--------------------评价简介Item信息---------------------
@interface CZJMyEvaluationGoodsForm : NSObject
@property (strong, nonatomic)NSString* storeItemPid;
@property (strong, nonatomic)NSString* itemName;
@property (strong, nonatomic)NSString* itemImg;
@property (strong, nonatomic)NSString* counterKey;
@property (strong, nonatomic)NSString* itemSku;
@property (strong, nonatomic)NSString* score;
@property (strong, nonatomic)NSString* message;
@property (strong, nonatomic)NSString* itemType;
@property (strong, nonatomic)NSMutableArray* evalImgs;
@end


//--------------------追加评价信息---------------------
@interface CZJAddedMyEvalutionForm : NSObject
@property (strong, nonatomic)NSArray* evalImgs;
@property (strong, nonatomic)NSString* evalTime;
@property (strong, nonatomic)NSString* message;
@end