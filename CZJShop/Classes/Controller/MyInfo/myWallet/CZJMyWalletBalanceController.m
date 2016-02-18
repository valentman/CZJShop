//
//  CZJMyWalletBalanceController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletBalanceController.h"
#import "CZJBaseDataManager.h"

@interface CZJMyWalletBalanceController ()
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@end

@implementation CZJMyWalletBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self getBalanceDataFromServer];
}

- (void)getBalanceDataFromServer
{
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        self.balanceLabel.text = [dict valueForKey:@"money"];
        self.notificationLabel.text = [dict valueForKey:@"title"];
    } andServerAPI:kCZJServerAPIGetBalanceInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
