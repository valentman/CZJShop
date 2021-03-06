//
//  CZJOrderLogisticsController.h
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJOrderLogisticsController : CZJViewController

@property (strong,  nonatomic)NSString* orderNo;
@end


@interface CZJLogisticsForm : NSObject
@property (strong,  nonatomic)NSString* expressName;
@property (strong,  nonatomic)NSString* expressNo;
@property (strong,  nonatomic)NSArray* items;
@end

@interface CZJLogisticsGoodItemForm : NSObject
@property (strong,  nonatomic)NSString* itemImg;
@property (strong,  nonatomic)NSString* itemName;
@end