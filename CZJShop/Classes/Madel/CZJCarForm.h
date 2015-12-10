//
//  CZJCarForm.h
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CZJCarForm : NSObject
{
    NSMutableArray* _carBrandsForms;    //汽车品牌列表
    NSMutableArray* _haveCarsForms;      //已有车辆
}
@property(nonatomic,strong)NSMutableArray* carBrandsForms;
@property(nonatomic,strong)NSMutableArray* haveCarsForms;

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)setNewDictionary:(NSDictionary*)dictionary;
-(void)cleanData;
@end


//---------------------汽车品牌信息----------------------
@interface CarBrandsForm : NSObject
@property(nonatomic, strong) NSString* icon;
@property(nonatomic, strong) NSString* initial;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* brandId;

- (id)initWithDictionary:(NSDictionary*)dict;
@end

//---------------------已有车辆信息----------------------
@interface HaveCarsForm : NSObject
@property(nonatomic, strong) NSString* modelId;
@property(nonatomic, strong) NSString* icon;
@property(nonatomic, strong) NSString* carId;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* dftFlag;

- (id)initWithDictionary:(NSDictionary*)dict;
@end