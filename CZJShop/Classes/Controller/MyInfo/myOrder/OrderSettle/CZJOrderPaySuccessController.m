//
//  CZJOrderPaySuccessController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/8/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderPaySuccessController.h"

@interface CZJOrderPaySuccessController ()
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *payNumber;

- (IBAction)showOrderAction:(id)sender;
- (IBAction)backToHomeAction:(id)sender;

@end

@implementation CZJOrderPaySuccessController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showOrderAction:(id)sender {
}

- (IBAction)backToHomeAction:(id)sender {
}
@end
