//
//  CZJEvaluateForm.h
//  CZJShop
//
//  Created by Joe.Pen on 2/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CZJAddedMyEvalutionForm;

@interface CZJEvaluateForm : NSObject
@property (assign, nonatomic)BOOL added;
@property (strong, nonatomic)CZJAddedMyEvalutionForm* addedEval;
@property (strong, nonatomic)NSString* chezhuId;
@property (strong, nonatomic)NSString* chezhuMobile;
@property (strong, nonatomic)NSString* counterKey;
@property (strong, nonatomic)NSString* createTime;
@property (strong, nonatomic)NSArray* evalImgs;
@property (strong, nonatomic)NSString* evalLevel;
@property (strong, nonatomic)NSString* evalTime;
@property (strong, nonatomic)NSString* hasImg;
@property (strong, nonatomic)NSString* head;
@property (strong, nonatomic)NSString* evaluateID;
@property (strong, nonatomic)NSString* itemImg;
@property (strong, nonatomic)NSString* itemName;
@property (strong, nonatomic)NSString* itemSku;
@property (strong, nonatomic)NSString* message;
@property (strong, nonatomic)NSString* name;
@property (strong, nonatomic)NSString* orderNo;
@property (strong, nonatomic)NSString* orderTime;
@property (strong, nonatomic)NSString* replyCount;
@property (strong, nonatomic)NSString* score;
@property (strong, nonatomic)NSString* storeId;
@property (strong, nonatomic)NSString* storeItemPid;
@end


@interface CZJMyEvaluationForm : NSObject
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

@interface CZJMyEvaluationGoodsForm : NSObject
@property (strong, nonatomic)NSString* storeItemPid;
@property (strong, nonatomic)NSString* itemName;
@property (strong, nonatomic)NSString* itemImg;
@property (strong, nonatomic)NSString* counterKey;
@property (strong, nonatomic)NSString* itemSku;
@property (strong, nonatomic)NSString* score;
@property (strong, nonatomic)NSString* message;
@property (strong, nonatomic)NSMutableArray* evalImgs;
@end

@interface CZJAddedMyEvalutionForm : NSObject
@property (strong, nonatomic)NSArray* evalImgs;
@property (strong, nonatomic)NSString* evalTime;
@property (strong, nonatomic)NSString* message;
@end