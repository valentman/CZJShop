//
//  CZJNaviagtionBarView.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJNaviagtionBarView.h"

@interface CZJNaviagtionBarView ()<UISearchBarDelegate>

@property(strong, nonatomic)UIButton* btnScan;
@property(strong, nonatomic)UIButton* btnShop;
@property(strong, nonatomic)UISearchBar* customSearchBar;


- (void)initWithButtons;
@end

@implementation CZJNaviagtionBarView


- (instancetype)initWithFrame:(CGRect)bounds AndTag:(NSInteger)tag
{
    if (self == [super initWithFrame:bounds]) {
        [self initWithButtons];
        [self setTag:tag];
        return self;
    }
    return nil;
}





- (void)initWithButtons
{
    //导航栏添加搜索栏
    CGRect mainViewBounds = self.bounds;
    _customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(CGRectGetMinX(mainViewBounds) + 44,
                                                                    (CGRectGetMaxY(mainViewBounds) - 40) / 2 ,
                                                                    mainViewBounds.size.width - (44 * 2),
                                                                    40)];
    _customSearchBar.delegate = self;
    _customSearchBar.backgroundColor = CLEARCOLOR;
    _customSearchBar.backgroundImage = [UIImage imageNamed:@"nav_bargound"];
    _customSearchBar.placeholder = @"搜索商品、服务项目门店名称";
    
    
    //导航栏添加扫一扫、购物车按钮
    _btnScan = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(mainViewBounds), 0, 44, 44)];
    [_btnScan setBackgroundImage:[UIImage imageNamed:@"btn_saoyisao"] forState:UIControlStateNormal];
    [_btnScan addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScan setTag:CZJButtonTypeHomeScan];
    
    _btnShop = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mainViewBounds) - 44, 0, 44, 44)];
    [_btnShop setBackgroundImage:[UIImage imageNamed:@"all_btn_shopping"] forState:UIControlStateNormal];
    [_btnShop addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnShop setTag:CZJButtonTypeHomeShopping];
    [self addSubview:_customSearchBar];
    [self addSubview:_btnScan];
    [self addSubview:_btnShop];
}


#pragma mark- UISearchBarDelegate
// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //这里做跳转
    return NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)clickButton:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickEventCallBack:)]) {
        [_delegate clickEventCallBack:sender];
    }
}

@end
