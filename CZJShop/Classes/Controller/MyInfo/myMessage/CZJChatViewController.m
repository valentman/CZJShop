//
//  CZJChatViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 5/6/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChatViewController.h"
#import "CZJNaviagtionBarView.h"

@interface CZJChatViewController ()
<
CZJNaviagtionBarViewDelegate,
UIGestureRecognizerDelegate
>
@property (strong , nonatomic)CZJNaviagtionBarView* naviBarView;
@end

@implementation CZJChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.naviBarView.mainTitleLabel.text = self.storeName;
}

- (void)addCZJNaviBarView:(CZJNaviBarViewType)naviBarViewType
{
    self.navigationController.navigationBarHidden = YES;
    [self addCZJNaviBarViewWithNotHiddenNavi:naviBarViewType];
}

- (void)addCZJNaviBarViewWithNotHiddenNavi:(CZJNaviBarViewType)naviBarViewType
{
    _naviBarView = [[CZJNaviagtionBarView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44) AndType:naviBarViewType];
    _naviBarView.delegate = self;
    [self.view addSubview:_naviBarView];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - CZJNaviagtionBarViewDelegate(自定义导航栏按钮回调)
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
