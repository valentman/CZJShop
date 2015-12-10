//
//  MGBaseViewController.m
//  JDSelectDemo
//
//  Created by mark on 15/8/3.
//  Copyright (c) 2015年 mark. All rights reserved.
//

#import "MGBaseViewController.h"

@interface MGBaseViewController ()

@end


@implementation MGBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_red"] style:UIBarButtonItemStylePlain target:self action:@selector(navBackBarAction:)];
    self.navigationItem.leftBarButtonItem = backBarItem;
    
    
    // Do any additional setup after loading the view.
}

- (void)navBackBarAction:(UINavigationItem *)bar{

    if (self.navigationController.viewControllers.count > 1) {
      [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
}

- (void)setTitle:(NSString *)title{
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, (PJ_SCREEN_WIDTH - kMGLeftSpace - 100)/2,100 , self.navigationController.navigationBar.frame.size.height)];
    self.lblTitle.text = title;
    self.navigationItem.titleView = self.lblTitle;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
