//
//  CZJBuyNoticeController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJBuyNoticeController.h"


#define NNRandomColor NNColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
@interface CZJBuyNoticeController ()
@end

@implementation CZJBuyNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
    
    NSString* apiType;
    if (CZJDetailTypeGoods == self.detaiViewType)
    {
        apiType = kCZJServerAPIGoodsBuyNoteDetail;
    }
    else
    {
        apiType = kCZJServerAPIServiceBuyNoteDetail;
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?storeItemPid=%@&itemCode=%@", kCZJServerAddr, apiType,[USER_DEFAULT valueForKey:kUserDefaultDetailStoreItemPid], [USER_DEFAULT valueForKey:kUserDefaultDetailItemCode]];
    [self loadWebPageWithString:url];
}
@end
