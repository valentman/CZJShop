//
//  CZJNaviagtionBarView.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJNaviagtionBarViewDelegate <NSObject>

- (void)clickEventCallBack:(nullable id)sender;

@end

@interface CZJNaviagtionBarView : UIView
@property(nullable, strong, nonatomic)UIButton* btnBack;
@property(nullable, strong, nonatomic)UIButton* btnScan;
@property(nullable, strong, nonatomic)UIButton* btnShop;
@property(nullable, strong, nonatomic)UIButton* btnMore;
@property(nullable, strong, nonatomic)UILabel* btnShopBadgeLabel;
@property(nullable, strong, nonatomic)UISearchBar* customSearchBar;
@property(nullable,nonatomic,weak) id<CZJNaviagtionBarViewDelegate> delegate;
- (nullable instancetype)initWithFrame:(CGRect)bounds AndType:(CZJViewType)type;

@end
