//
//  CZJAfterServiceController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJAfterServiceController.h"

@interface CZJAfterServiceController ()

@end

@implementation CZJAfterServiceController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog(@"CZJApplicableCarController");
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsAfterSaleDetail;
    }
    else
    {
        apiType = kCZJServerAPIServicePicDetail;
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [self loadWebPageWithString:url];
}
@end
