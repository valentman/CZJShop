//
//  CZJBaseTabBarController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/15/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJBaseTabBarController.h"

@interface CZJBaseTabBarController ()

@end

@implementation CZJBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.backgroundColor = RGB(0, 0, 0);
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
@end
