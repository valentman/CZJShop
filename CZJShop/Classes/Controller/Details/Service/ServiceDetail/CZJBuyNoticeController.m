//
//  CZJBuyNoticeController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJBuyNoticeController.h"
// 颜色
#define NNColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
// 随机色
#define NNRandomColor NNColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
@interface CZJBuyNoticeController ()

@end

@implementation CZJBuyNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = NNRandomColor;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"CZJBuyNoticeController");
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
