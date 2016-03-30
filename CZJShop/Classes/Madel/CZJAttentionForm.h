//
//  CZJAttentionForm.h
//  CZJShop
//
//  Created by Joe.Pen on 1/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJGoodsAttentionForm : NSObject
@property(strong, nonatomic) NSString* chezhuId;
@property(strong, nonatomic) NSString* createTime;
@property(strong, nonatomic) NSString* currentPrice;
@property(strong, nonatomic) NSString* attentionID;
@property(strong, nonatomic) NSString* itemImg;
@property(strong, nonatomic) NSString* itemName;
@property(strong, nonatomic) NSString* itemType;
@property(strong, nonatomic) NSString* storeItemPid;
@property(assign)BOOL isSelected;

- (id)init;
@end


@interface CZJStoreAttentionForm : NSObject
@property(strong, nonatomic) NSString* attentionCount;
@property(strong, nonatomic) NSString* chezhuId;
@property(strong, nonatomic) NSString* createTime;
@property(strong, nonatomic) NSString* homeImg;
@property(strong, nonatomic) NSString* attentionID;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* storeId;
@property(assign)BOOL isSelected;

- (id)init;
@end

