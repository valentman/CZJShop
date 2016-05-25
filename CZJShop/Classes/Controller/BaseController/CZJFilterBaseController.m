//
//  CZJFilterBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJFilterBaseController.h"

@interface CZJFilterBaseController ()
@end

@implementation CZJFilterBaseController

- (instancetype)initWithType:(CZJCarListType)type
{
    if (self = [super init])
    {
        self.carlistType = type;
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_carlistType == CZJCarListTypeGeneral)
    {
        [CZJUtils customizeNavigationBarForTarget:self];
    }
    else
    {
        //UIButton
        UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
        [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
        [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [leftBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
        [leftBtn setTag:1000];
        //UIBarButtonItem
        UIBarButtonItem *leftItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
        [leftItem setTag:1000];
    }
}

- (void)cancelAction:(UIBarButtonItem *)bar
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)navBackBarAction:(UIBarButtonItem *)bar{

}

- (void)setTitle:(NSString *)title{
    
    CGRect titleRect = CGRectMake(0, (PJ_SCREEN_WIDTH - kMGLeftSpace - 50)/2,100 , self.navigationController.navigationBar.frame.size.height);
    if (IS_IOS9)
    {
        self.navigationItem.title = title;
    }
    
    else if (IS_IOS8 || IS_IOS7)
    {
        self.lblTitle = [[UILabel alloc] initWithFrame:titleRect];
        self.lblTitle.text = title;
        self.lblTitle.font = [UIFont systemFontOfSize:19];
        self.navigationItem.titleView = self.lblTitle;
    }
}

- (UIBarButtonItem *)spacerWithSpace:(CGFloat)space
{
    UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBar.width = space;
    return spaceBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
