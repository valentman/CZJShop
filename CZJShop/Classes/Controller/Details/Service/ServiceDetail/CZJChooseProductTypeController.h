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


@protocol CZJChooseProductTypeDelegate <NSObject>

- (void)productTypeImeditelyBuyCallBack;
- (void)productTypeAddtoShoppingCartCallBack;

@end

@interface CZJChooseProductTypeController : CZJViewController
@property (strong, nonatomic)CZJGoodsDetail* goodsDetail;
@property (assign, nonatomic)NSInteger buycount;
@property (weak, nonatomic) id<CZJChooseProductTypeDelegate> delegate;
@property (nonatomic, copy) MGBasicBlock basicBlock;

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;
- (void)getSKUDataFromServer;
@end
