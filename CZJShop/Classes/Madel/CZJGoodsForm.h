//
//  CZJGoodsForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZJStoreForm.h"

@interface CZJGoodsForm : NSObject
{
    NSMutableArray* _goodsList;          //商品信息列表
}
@property(nonatomic, strong)NSMutableArray* goodsList;

- (id)init;
- (void)setNewDictionary:(NSDictionary*)dict WithType:(CZJHomeGetDataFromServerType)type;
- (void)appendNewGoodsData:(NSDictionary*)dict;
- (void)resetData;

@end
