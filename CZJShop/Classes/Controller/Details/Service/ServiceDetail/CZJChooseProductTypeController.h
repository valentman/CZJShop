//
//  CZJChooseProductTypeController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"
#import "CZJGoodsDetailForm.h"

@interface CZJLevelSku : NSObject
@property(strong, nonatomic)NSString* valueId;
@property(strong, nonatomic)NSString* valueName;
@property(strong, nonatomic)NSMutableArray* twoSkus;
@end

@protocol CZJChooseProductTypeDelegate <NSObject>

- (void)productTypeImeditelyBuyCallBack;
- (void)productTypeAddtoShoppingCartCallBack;

@end

@interface CZJChooseProductTypeController : CZJFilterBaseController
@property (strong, nonatomic)CZJGoodsDetail* goodsDetail;
@property (assign, nonatomic)NSInteger buycount;
@property (weak, nonatomic) id<CZJChooseProductTypeDelegate> delegate;
@property (nonatomic, copy) MGBasicBlock basicBlock;

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
- (void)getSKUDataFromServer;
@end
