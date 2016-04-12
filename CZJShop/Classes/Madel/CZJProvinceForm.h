//
//  CZJProvinceForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/3/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJProvinceForm : NSObject
{
    NSMutableArray* _containCitys;
}
@property(nonatomic, strong) NSString* provinceId;
@property(nonatomic, strong) NSString* total;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSMutableArray* containCitys;

- (id)initWithDictionary:(NSDictionary*)dict;

@end

//----------------------所有开通省份城市信息----------------------------
@interface CZJCitysForm : NSObject
@property(nonatomic, strong) NSString* provinceId;
@property(nonatomic, strong) NSString* total;
@property(nonatomic, strong) NSString* cityId;
@property(nonatomic, strong) NSString* name;
@end