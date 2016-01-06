//
//  CZJApplicableCarController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/29/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJApplicableCarController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface CZJApplicableCarController ()
@end

@implementation CZJApplicableCarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsCarModelList;
    }
    else
    {
        apiType = kCZJServerAPIServiceCarModelsList;
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [self loadWebPageWithString:url];
}
@end
