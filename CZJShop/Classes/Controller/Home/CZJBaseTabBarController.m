//
//  CZJBaseTabBarController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/15/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJBaseTabBarController.h"
#import "CZJMessageManager.h"

@interface CZJBaseTabBarController ()

@property (strong, nonatomic) UILabel* dotLabel;
@end

@implementation CZJBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.backgroundColor = RGB(0, 0, 0);
    
    //添加小红点标记
    _dotLabel = [[UILabel alloc]initWithSize:CGSizeMake(8, 8)];
    _dotLabel.backgroundColor = CZJREDCOLOR;
    _dotLabel.layer.cornerRadius = 4;
    _dotLabel.clipsToBounds = YES;
    CGPoint dotPt;
    if (iPhone5)
    {
        dotPt = CGPointMake(PJ_SCREEN_WIDTH - 15, 5);
    }
    if (iPhone6)
    {
        dotPt = CGPointMake(PJ_SCREEN_WIDTH - 20, 5);
    }
    if (iPhone6Plus)
    {
        dotPt = CGPointMake(PJ_SCREEN_WIDTH - 25, 5);
    }
    [_dotLabel setPosition:dotPt atAnchorPoint:CGPointTopRight];
    _dotLabel.hidden = YES;
    [self.tabBar addSubview:_dotLabel];
    
//    [self refreshTabBarDotLabel];
//    //注册接收有新消息显示小红点通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTabBarDotLabel) name:kCZJNotifiRefreshMessageReadStatus object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTabBarDotLabel) name:kCZJNotifiLoginSuccess object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTabBarDotLabel) name:kCZJNotifiLoginOut object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    //判断是否相等,不同才设置
    if (self.selectedIndex != selectedIndex) {
        //设置最近一次
        _lastSelectedIndex = self.selectedIndex;
        DLog(@"1 OLD:%ld , NEW:%ld",self.lastSelectedIndex,selectedIndex);
    }
    
    //调用父类的setSelectedIndex
    [super setSelectedIndex:selectedIndex];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //获得选中的item
    NSUInteger tabIndex = [tabBar.items indexOfObject:item];
    if (tabIndex != self.selectedIndex) {
        //设置最近一次变更
        _lastSelectedIndex = self.selectedIndex;
        DLog(@"2 OLD:%ld , NEW:%ld",self.lastSelectedIndex,tabIndex);
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

- (void)refreshTabBarDotLabel
{
    if ([USER_DEFAULT boolForKey:kCZJIsUserHaveLogined]) {
        _dotLabel.hidden = [CZJMessageInstance isAllReaded];
    }
    else
    {
        _dotLabel.hidden = YES;
    }
}

@end
