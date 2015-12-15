//
//  CZJServiceListController.h
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJViewControllerDelegate.h"
#import "MXPullDownMenu.h"
#import "PullTableView.h"
#import "CZJStoreForm.h"

@interface CZJServiceListController : UIViewController
{
    NSString* _choosedStoreitemPid;
    BOOL isFirstIn;
}

@property (nonatomic, assign) EWEBTYPE curType;
@property (nonatomic, assign) EWebHtmlType  htmlType;
@property (retain, nonatomic) NSString* itemId;
@property (strong, nonatomic) NSString *onlineUrl;
@property (strong, nonatomic) NSString *navTitleName;
@property (strong, nonatomic) NSString *typeId;
@property (assign, nonatomic) BOOL moreFlag;
@property (assign, nonatomic) int  sortType;
@property (weak, nonatomic) id <CZJViewControllerDelegate> delegate;

@end
