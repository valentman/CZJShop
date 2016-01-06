//
//  CZJChooseProductTypeController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJFilterBaseController.h"
#import "CZJDetailForm.h"

@interface CZJLevelSku : NSObject
@property(strong, nonatomic)NSString* valueId;
@property(strong, nonatomic)NSString* valueName;
@property(strong, nonatomic)NSMutableArray* nextLevelSkus;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

@interface CZJChooseProductTypeController : CZJFilterBaseController
@property (strong, nonatomic)NSString* storeItemPid;
@property (strong, nonatomic)CZJGoodsSKU* currentSku;
@property (strong, nonatomic)NSString* counterKey;

- (void)getSKUDataFromServer;
@end
