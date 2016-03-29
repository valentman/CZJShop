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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *balanceLabelWidth;

@end

@implementation CZJMyWalletBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self getBalanceDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)getBalanceDataFromServer
{
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        self.balanceLabel.text = [dict valueForKey:@"money"];
        self.balanceLabelWidth.constant = [CZJUtils calculateTitleSizeWithString:[dict valueForKey:@"money"] AndFontSize:24].width + 5;
        self.notificationLabel.text = [dict valueForKey:@"title"];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIGetBalanceInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
