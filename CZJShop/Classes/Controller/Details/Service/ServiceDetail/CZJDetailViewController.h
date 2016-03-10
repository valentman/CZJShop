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
@property (nonatomic, strong)NSString* promotionType;
@property (nonatomic, strong)NSString* promotionPrice;
@property (nonatomic, assign)CZJDetailType detaiViewType;
@end
