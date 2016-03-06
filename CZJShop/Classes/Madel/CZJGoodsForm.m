//
//  CZJGoodsForm.m
//  CZJShop
//
//  Created by Joe.Pen on 12/14/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsForm.h"

@implementation CZJGoodsForm
@synthesize goodsList = _goodsList;

- (id)initWithDictionary:(NSDictionary*)dict WithType:(CZJHomeGetDataFromServerType)type
{
    if (self  = [super init])
    {
        _goodsList = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (void)setNewDictionary:(NSDictionary*)dict WithType:(CZJHomeGetDataFromServerType)type
{
    if (CZJHomeGetDataFromServerTypeOne == type)
    {
        [self resetData];
    }
    
    [self appendNewGoodsData:dict];
}

- (void)appendNewGoodsData:(NSDictionary*)dict
{
    NSArray* tmpAry = [dict valueForKey:@"msg"];
    _goodsList = [[CZJStoreServiceForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
}


- (void)resetData
{
    [_goodsList removeAllObjects];
}
@end
