//
//  CZJNaviagtionBarView.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJNaviagtionBarView.h"

@interface CZJNaviagtionBarView ()<UISearchBarDelegate>
{
    CGRect _selfBounds;
}



- (void)initWithButtonsWithType:(CZJViewType)type;
@end

@implementation CZJNaviagtionBarView
@synthesize btnBack = _btnBack;
@synthesize btnScan = _btnScan;
@synthesize btnShop = _btnShop;
@synthesize customSearchBar = _customSearchBar;

- (instancetype)initWithFrame:(CGRect)bounds AndType:(CZJViewType)type
{
    if (self == [super initWithFrame:bounds]) {
        _selfBounds = bounds;
        [self initWithButtonsWithType:type];
        [self setTag:type];
        return self;
    }
    return nil;
}

- (void)initWithButtonsWithType:(CZJViewType)type
{
    //状态栏颜色
    CGRect statusviewbound = CGRectMake(0, -20, _selfBounds.size.width, 20);
    UIView* _statusBarBgView = [[UIView alloc]initWithFrame:statusviewbound];
    [self  addSubview:_statusBarBgView];
    
    //导航栏添加搜索栏
    _customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(CGRectGetMinX(_selfBounds) + 44,
                                                                    (CGRectGetMaxY(_selfBounds) - 40) / 2 ,
                                                                    _selfBounds.size.width - (44 * 2),
                                                                    40)];
    _customSearchBar.delegate = self;
    _customSearchBar.backgroundColor = CLEARCOLOR;
    _customSearchBar.backgroundImage = [UIImage imageNamed:@"nav_bargound"];
    _customSearchBar.placeholder = @"搜索商品、服务项目门店名称";
    
    
    NSString* shopBtnImageName = @"all_btn_shopping";
    NSString* saoyisaoBtnImageName = @"btn_saoyisao";
    switch (type) {
        case CZJViewTypeNaviBarViewCategory:
            saoyisaoBtnImageName = @"all_btn_saoyisao";
            shopBtnImageName = @"btn_shopping";
            [_statusBarBgView setBackgroundColor:UIColorFromRGB(0xF3F4F6)];
        case CZJViewTypeNaviBarView:
            //导航栏添加扫一扫
            _btnScan = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
            [_btnScan setBackgroundImage:[UIImage imageNamed:saoyisaoBtnImageName] forState:UIControlStateNormal];
            [_btnScan addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [_btnScan setTag:CZJButtonTypeHomeScan];
            break;
            
        case CZJViewTypeNaviBarViewBack:
            //导航栏返回按钮
            [_statusBarBgView setBackgroundColor:RGB(239, 239, 239)];
            _btnBack = [[ UIButton alloc ]initWithFrame:CGRectMake(0, 0, 44, 44)];
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_backnor"] forState:UIControlStateNormal];
            [_btnBack addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [_btnBack setTag:CZJButtonTypeNaviBarBack];
            shopBtnImageName = @"btn_shopping";
            break;
            
        default:
            break;
    }
    //购物车按钮
    _btnShop = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_selfBounds) - 44, 0, 44, 44)];
    [_btnShop setBackgroundImage:[UIImage imageNamed:shopBtnImageName] forState:UIControlStateNormal];
    [_btnShop addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnShop setTag:CZJButtonTypeHomeShopping];
    [self addSubview:_customSearchBar];
    [self addSubview:_btnScan];
    [self addSubview:_btnShop];
    [self addSubview:_btnBack];
    

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
