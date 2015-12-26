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

- (void)initWithButtonsWithType:(CZJNaviBarViewType)type;
@end

@implementation CZJNaviagtionBarView
@synthesize btnBack = _btnBack;
@synthesize btnScan = _btnScan;
@synthesize btnShop = _btnShop;
@synthesize btnArrange = _btnArrange;
@synthesize btnMore = _btnMore;
@synthesize btnShopBadgeLabel = _btnShopBadgeLabel;
@synthesize customSearchBar = _customSearchBar;

- (instancetype)initWithFrame:(CGRect)bounds AndType:(CZJNaviBarViewType)type
{
    if (self == [super initWithFrame:bounds]) {
        _selfBounds = bounds;
        [self initWithButtonsWithType:type];
        [self setTag:type];
        return self;
    }
    return nil;
}

- (void)initWithButtonsWithType:(CZJNaviBarViewType)type
{
    //状态栏颜色
    CGRect statusviewbound = CGRectMake(0, -20, _selfBounds.size.width, 20);
    UIView* _statusBarBgView = [[UIView alloc]initWithFrame:statusviewbound];
    [self  addSubview:_statusBarBgView];
    
    //初始化数据
    NSString* shopBtnImageName = @"all_btn_shopping";
    NSString* saoyisaoBtnImageName = @"btn_saoyisao";
    NSString* arrangeBtnImageName = @"pro_btn_large";
    
    //------------------------------------初始化按钮组------------------------------------
    //1.搜索栏按钮
    CGRect searchaBarRect = CGRectMake(CGRectGetMinX(_selfBounds) + 44,
                                       (CGRectGetMaxY(_selfBounds) - 40) / 2 ,
                                       _selfBounds.size.width - (44 * 2),
                                       40);
    _customSearchBar = [[UISearchBar alloc] initWithFrame:searchaBarRect];
    _customSearchBar.delegate = self;
    _customSearchBar.backgroundColor = CLEARCOLOR;
    _customSearchBar.backgroundImage = [UIImage imageNamed:@"nav_bargound"];
    _customSearchBar.placeholder = @"搜索商品、服务项目门店名称";
    [_customSearchBar setTag:CZJButtonTypeSearchBar];
    _customSearchBar.hidden = NO;
    
    //2.扫一扫按钮
    CGRect btnScanRect = CGRectMake(0, 0, 44, 44);
    _btnScan = [[UIButton alloc]initWithFrame:btnScanRect];
    [_btnScan setBackgroundImage:[UIImage imageNamed:saoyisaoBtnImageName] forState:UIControlStateNormal];
    [_btnScan addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScan setTag:CZJButtonTypeHomeScan];
    [_btnScan setHidden:YES];
    
    //3.返回按钮
    CGRect btnBackRect = CGRectMake(0, 0, 44, 44);
    _btnBack = [[ UIButton alloc ]initWithFrame:btnBackRect];
    [_btnBack setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_backnor"] forState:UIControlStateNormal];
    [_btnBack addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnBack setTag:CZJButtonTypeNaviBarBack];
    [_btnBack setHidden:YES];
    
    //4.更多按钮
    CGRect btnMoreRect = CGRectMake(CGRectGetMaxX(_selfBounds) - 58, 2, 40, 40);
    _btnMore = [[ UIButton alloc ]initWithFrame:btnMoreRect];
    [_btnMore setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_more"] forState:UIControlStateNormal];
    [_btnMore addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnMore setTag:CZJButtonTypeNaviBarMore];
    [_btnMore setHidden:YES];
    
    //5.购物车按钮
    CGRect btnShopRect = CGRectMake(CGRectGetMaxX(_selfBounds) - 44, 0, 44, 44);
    _btnShop = [[UIButton alloc]initWithFrame:btnShopRect];
    [_btnShop setBackgroundImage:[UIImage imageNamed:shopBtnImageName] forState:UIControlStateNormal];
    [_btnShop addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnShop setTag:CZJButtonTypeHomeShopping];
    [_btnShop setHidden:YES];
    
    _btnShopBadgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, -2, 20, 20)];
    _btnShopBadgeLabel.textColor = [UIColor whiteColor];
    _btnShopBadgeLabel.text = @"20";
    _btnShopBadgeLabel.font = [UIFont boldSystemFontOfSize:11];
    
    _btnShopBadgeLabel.textAlignment = NSTextAlignmentCenter;
    _btnShopBadgeLabel.layer.backgroundColor = [UIColor redColor].CGColor;
    _btnShopBadgeLabel.layer.cornerRadius = 10;
    _btnShopBadgeLabel.hidden = YES;
    [_btnShop addSubview:_btnShopBadgeLabel];
    if (CZJNaviBarViewTypeDetail == type) {
        _btnShopBadgeLabel.hidden = NO;
    }
    
    //6.列表分类按钮
    CGRect btnArrangeRect = CGRectMake(CGRectGetMaxX(_selfBounds) - 44, 10, 24, 24);
    _btnArrange = [[UIButton alloc]initWithFrame:btnArrangeRect];
    [_btnArrange setBackgroundImage:[UIImage imageNamed:arrangeBtnImageName] forState:UIControlStateNormal];
    [_btnArrange addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnArrange setTag:CZJButtonTypeNaviArrange];
    [_btnArrange setHidden:YES];

    
    switch (type) {
        case CZJNaviBarViewTypeCategory:
            //分类扫一扫按钮和购物车按钮背景图片不一样
            [_btnScan setHidden:NO];
            [_btnShop setHidden:NO];
            saoyisaoBtnImageName = @"all_btn_saoyisao";
            shopBtnImageName = @"btn_shopping";
            [_btnShop setBackgroundImage:[UIImage imageNamed:shopBtnImageName] forState:UIControlStateNormal];
            [_btnScan setBackgroundImage:[UIImage imageNamed:saoyisaoBtnImageName] forState:UIControlStateNormal];
            [_statusBarBgView setBackgroundColor:UIColorFromRGB(0xF3F4F6)];
            break;
            
        case CZJNaviBarViewTypeHome:
            //导航栏添加扫一扫
            [_btnScan setHidden:NO];
            [_btnShop setHidden:NO];
            break;
            
        case CZJNaviBarViewTypeBack:
            //导航栏返回按钮
            [_btnBack setHidden:NO];
            [_btnShop setHidden:NO];
            shopBtnImageName = @"btn_shopping";
            [_btnShop setBackgroundImage:[UIImage imageNamed:shopBtnImageName] forState:UIControlStateNormal];
            [_statusBarBgView setBackgroundColor:RGB(239, 239, 239)];
            break;
            
        case CZJNaviBarViewTypeDetail:
            //详情界面返回按钮，购物车，更多按钮，且图片和位置都不同
            //只有详情界面不需要导航栏
            [_btnBack setHidden:NO];
            [_btnShop setHidden:NO];
            [_btnMore setHidden:NO];
            [_customSearchBar setHidden:YES];
            
            btnBackRect =  CGRectMake(14, 2, 40, 40);
             _btnBack.frame = btnBackRect;
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_back"] forState:UIControlStateNormal];
           
            btnMoreRect = CGRectMake(CGRectGetMaxX(_selfBounds) - 58, 2, 40, 40);
            _btnMore.frame = btnMoreRect;
            [_btnMore setBackgroundImage:[UIImage imageNamed:@"prodetail_btn_more"] forState:UIControlStateNormal];

            shopBtnImageName = @"prodetail_btn_shop";
            btnShopRect = CGRectMake(CGRectGetMaxX(_selfBounds) - 112, 2, 40, 40);
            _btnShop.frame = btnShopRect;
            [_btnShop setBackgroundImage:[UIImage imageNamed:shopBtnImageName] forState:UIControlStateNormal];
            break;
            
        case CZJNaviBarViewTypeGoodsList:
            //商品列表界面
            [_btnBack setHidden:NO];
            [_btnArrange setHidden:NO];
            break;
            
        default:
            break;
    }

    [self addSubview:_customSearchBar];
    [self addSubview:_btnScan];
    [self addSubview:_btnShop];
    [self addSubview:_btnBack];
    [self addSubview:_btnMore];
    [self addSubview:_btnArrange];
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
