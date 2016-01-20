//
//  CZJViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/22/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJViewController.h"

@interface CZJViewController ()

@end

@implementation CZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCZJNaviBarView
{
    self.navigationController.navigationBarHidden = YES;
    _naviBarView = [[CZJNaviagtionBarView alloc]initWithFrame:CGRectMake(0, 20, PJ_SCREEN_WIDTH, 44) AndType:CZJNaviBarViewTypeGeneral];
    [self.view addSubview:_naviBarView];
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
