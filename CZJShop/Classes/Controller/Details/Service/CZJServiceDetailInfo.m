//
//  CZJDetailInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceDetailInfo.h"

@interface CZJServiceDetailInfo ()<UIGestureRecognizerDelegate>

@end

@implementation CZJServiceDetailInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];
    
//    [CZJUtils printClassMethodList:self];
//    [CZJUtils printClassMethodList:pan];
    
    
    UIGestureRecognizer* gesture = self.navigationController.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    UIView* gestureView = gesture.view;
    
    NSMutableArray* _targets = [gesture valueForKey:@"_targets"];
    id gestureRecogizerTarget = [_targets firstObject];
    id navigationInteractiveTransition = [gestureRecogizerTarget valueForKey:@"_target"];
    SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:navigationInteractiveTransition action:handleTransition];
    [gestureView addGestureRecognizer:pan];
    
//    //setp1:需要获取系统自带滑动手势的target对象
//    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
//    // setp2:创建全屏滑动手势~调用系统自带滑动手势的target的action方法
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
//    //step3:设置手势代理~拦截手势触发
//    pan.delegate = self;
//    //step4:别忘了~给导航控制器的view添加全屏滑动手势
//    [self.view addGestureRecognizer:pan];
//    //step5:将系统自带的滑动手势禁用
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

}

//- (void)backLastView:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
