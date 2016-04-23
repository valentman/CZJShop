//
//  MultilevelMenu.h
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLeftWidth ((iPhone4 || iPhone5) ? 88 : 100)
typedef void (^SelectBlock)(NSInteger, NSInteger, id);

@interface MultilevelMenu : UIView<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

@property(strong,nonatomic,readonly) NSArray * allData;
@property(copy,nonatomic,readonly) SelectBlock block;
@property(assign,nonatomic) BOOL isRecordLastScroll;
@property(assign,nonatomic) NSInteger selectIndex;
@property(assign)NSIndexPath* selelctIndexPath;

/**
 *  颜色属性配置
 */

/**
 *  左边背景颜色
 */
@property(strong,nonatomic) UIColor * leftBgColor;
/**
 *  左边点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftTitleSelectColor;
/**
 *  左边点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftSelectBgColor;
/**
 *  左边未点中文字颜色
 */
@property(strong,nonatomic) UIColor * leftTitleUnSelectColor;
/**
 *  左边未点中背景颜色
 */
@property(strong,nonatomic) UIColor * leftUnSelectBgColor;
/**
 *  tablew 的分割线
 */
@property(strong,nonatomic) UIColor * leftSeparatorColor;
/**
 *
 */
@property(nonatomic) NSInteger tabbarHeight;

-(id)initWithFrame:(CGRect)frame WithData:(NSArray*)data withSelectIndex:(SelectBlock)selectIndex;
-(void)reloadData;
@end


//广告数据
@interface BannerAdForm : NSObject
@property(copy, nonatomic)NSString* value;
@property(copy, nonatomic)NSString* img;
@property(copy, nonatomic)NSString* type;
@end

//
@interface rightMeun : NSObject

/**
 *  菜单图片名
 */
@property(copy,nonatomic) NSString * urlName;
/**
 *  菜单名
 */
@property(copy,nonatomic) NSString * meunName;
/**
 *  菜单ID
 */
@property(copy,nonatomic) NSString * typeId;
/**
 *  父菜单ID
 */
@property(copy,nonatomic) NSString * parentId;
/**
 *  下一级菜单
 */

@property(strong,nonatomic) NSMutableArray * nextArray;
/**
 *  菜单层数
 */

//广告数据
@property(strong,nonatomic) BannerAdForm* bannerAd;

@property(assign,nonatomic) NSInteger meunNumber;

@property(assign,nonatomic) float offsetScorller;

@end