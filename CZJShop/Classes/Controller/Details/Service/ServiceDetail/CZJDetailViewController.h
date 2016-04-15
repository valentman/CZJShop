//
//  CZJDetailViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJDetailViewController : CZJViewController
@property (nonatomic, strong)NSString* storeItemPid;
@property (nonatomic, assign)CZJDetailType detaiViewType;
@property (nonatomic, assign)CZJGoodsPromotionType promotionType;
@property (nonatomic, strong)NSString* promotionPrice;
@property (nonatomic, assign)NSInteger miaoShaInterval;
@property (nonatomic, strong)NSString* skillId;
@end
