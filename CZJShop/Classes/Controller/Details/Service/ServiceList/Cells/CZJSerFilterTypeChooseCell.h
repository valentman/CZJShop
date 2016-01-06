//
//  CZJSerFilterTypeChooseCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJButtonArrayCell.h"
#define kCZJSerFilterTypeChooseCellTypeService 1111         //服务列表筛选服务项目名称（首页展示的洗车，贴膜等服务）
#define kCZJSerFilterTypeChooseCellTypeGoWhere 1112         //服务列表筛选服务方式（到店服务还是上门服务）
#define kCZJSerFilterTypeChooseCellTypeGoods 1113           //商品列表筛选分类
#define kCZJSerfilterTypeChooseCellTypeDetail 1114          //详情界面选择产品型号筛选界面


@interface CZJSerFilterTypeChooseCell : CZJButtonArrayCell

@property(strong, nonatomic)CZJButtonBlock buttonBlock;
-(void)setButtonDatas:(NSArray *)buttonDatas WithType:(NSInteger)type;
- (void)setDefaultSelectBtn:(NSString*)selectdString;
@end
