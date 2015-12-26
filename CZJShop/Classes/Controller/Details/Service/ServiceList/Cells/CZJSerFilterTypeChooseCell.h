//
//  CZJSerFilterTypeChooseCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJButtonArrayCell.h"
#define kCZJSerFilterTypeChooseCellTypeService 1111
#define kCZJSerFilterTypeChooseCellTypeGoWhere 1112
#define kCZJSerFilterTypeChooseCellTypeGoods 1113


@interface CZJSerFilterTypeChooseCell : CZJButtonArrayCell


-(void)setButtonDatas:(NSArray *)buttonDatas WithType:(NSInteger)type;
@end
