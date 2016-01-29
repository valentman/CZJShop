//
//  CZJPicDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJPicDetailController.h"

// 随机色
#define NNRandomColor NNColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
@interface CZJPicDetailController ()
@end

@implementation CZJPicDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsPicDetails;
    }
    else
    {
        apiType = kCZJServerAPIServicePicDetail;
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [self loadWebPageWithString:url];
}

@end
