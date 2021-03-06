//
//  CZJNaviagtionBarView.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJNaviagtionBarViewDelegate <NSObject>

@optional
- (void)clickEventCallBack:(nullable id)sender;
- (void)removeShoppingOrLoginView:(nullable id)sender;

@end

@interface CZJNaviagtionBarView : UIView<UISearchBarDelegate, CZJViewControllerDelegate>
@property(nullable, strong, nonatomic)UIButton* btnBack;                            //返回按钮
@property(nullable, strong, nonatomic)UIButton* btnScan;                            //扫一扫按钮
@property(nullable, strong, nonatomic)UIButton* btnShop;                            //购物车
@property(nullable, strong, nonatomic)UIButton* btnMore;                            //更多按钮
@property(nullable, strong, nonatomic)UIButton* btnArrange;                         //列表排列样式按钮
@property(nullable, strong, nonatomic)UILabel* btnShopBadgeLabel;
@property(nullable, strong, nonatomic)UISearchBar* customSearchBar;                 //搜索栏
@property(nullable, strong, nonatomic)UILabel* mainTitleLabel;                      //正中标题
@property(nullable, strong, nonatomic)UIView* buttomSeparator;                      //底部分割线
@property (nonatomic, assign) CZJDetailType detailType;


@property(nullable,nonatomic,weak) id<CZJNaviagtionBarViewDelegate> delegate;
- (nullable instancetype)initWithFrame:(CGRect)bounds AndType:(CZJNaviBarViewType)type;
- (void)refreshShopBadgeLabel;
- (void)setBackgroundColor:(nullable UIColor *)backgroundColor;
@end
