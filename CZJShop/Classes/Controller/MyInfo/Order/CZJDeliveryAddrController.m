//
//  CZJDeliveryAddrController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJDeliveryAddrController.h"

@interface CZJDeliveryAddrController ()
@property (weak, nonatomic) IBOutlet UITableView *addrListTableView;

- (IBAction)goAddAddrAction:(id)sender;
@end

@implementation CZJDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)goAddAddrAction:(id)sender {
}
@end
