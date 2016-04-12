//
//  CZJMyCardInfoForm.h
//  CZJShop
//
//  Created by Joe.Pen on 2/18/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
//套餐卡列表界面数据
@interface CZJMyCardInfoForm : NSObject
@property(strong, nonatomic) NSArray* items;
@property(strong, nonatomic) NSString* setmenuId;
@property(strong, nonatomic) NSString* setmenuName;
@property(strong, nonatomic) NSString* storeId;
@property(strong, nonatomic) NSString* storeName;
@end

@interface CZJMyCardDetailInfoForm : NSObject
@property(strong, nonatomic) NSString* currentCount;
@property(strong, nonatomic) NSString* ID;
@property(strong, nonatomic) NSString* itemCode;
@property(strong, nonatomic) NSString* itemCost;
@property(strong, nonatomic) NSString* itemCount;
@property(strong, nonatomic) NSString* itemGrossProfit;
@property(strong, nonatomic) NSString* itemId;
@property(strong, nonatomic) NSString* itemName;
@property(strong, nonatomic) NSString* itemOriginal;
@property(strong, nonatomic) NSString* itemPrice;
@property(strong, nonatomic) NSString* setmenuFlag;
@property(strong, nonatomic) NSString* setmenuId;
@property(strong, nonatomic) NSArray* submenuItems;
@property(strong, nonatomic) NSString* totalPrice;
@property(strong, nonatomic) NSString* useCount;
@end


//套餐卡详情界面数据
@interface CZJCardDetailInfoForm : NSObject
@property(strong, nonatomic) NSString* createTime;
@property(strong, nonatomic) NSArray* items;
@end

@interface CZJCardDetailInfoFormItem : NSObject
@property(strong, nonatomic) NSString*  currentCount;
@property(strong, nonatomic) NSString*  customerSetmenuPid;
@property(strong, nonatomic) NSString*  giveFlag;
@property(strong, nonatomic) NSString*  ID;
@property(strong, nonatomic) NSString*  itemCode;
@property(strong, nonatomic) NSString*  itemCost;
@property(strong, nonatomic) NSString*  itemCount;
@property(strong, nonatomic) NSString*  itemId;
@property(strong, nonatomic) NSString*  itemName;
@property(strong, nonatomic) NSString*  itemOriginal;
@property(strong, nonatomic) NSString*  itemPrice;
@property(strong, nonatomic) NSString*  setmenuClosed;
@property(strong, nonatomic) NSString*  setmenuFlag;
@property(strong, nonatomic) NSString*  setmenuId;
@property(strong, nonatomic) NSString*  setmenuName;
@property(strong, nonatomic) NSArray*   submenuItems;
@property(strong, nonatomic) NSString*  totalPrice;
@property(strong, nonatomic) NSString*  useCount;
@end


@interface CZJRedpacketInfoForm : NSObject
@property(strong, nonatomic) NSString*  name;
@property(strong, nonatomic) NSString*  value;
@property(strong, nonatomic) NSString*  curValue;
@property(strong, nonatomic) NSString*  takeTime;
@end