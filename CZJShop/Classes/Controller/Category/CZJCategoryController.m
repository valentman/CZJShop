//
//  CZJCategoryController.m
//  CheZhiJian
//
//  Created by Joe.Pen on 11/11/15.
//  Copyright © 2015 chelifang. All rights reserved.
//

#import "CZJCategoryController.h"
#import "MultilevelMenu.h"
#import "CZJNaviagtionBarView.h"

@interface CZJCategoryController ()
@property(strong,nonatomic) MultilevelMenu * multiView;
@end

@implementation CZJCategoryController
@synthesize multiView = _multiView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray * lis=[NSMutableArray arrayWithCapacity:0];
    
    NSInteger tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    NSInteger statusbarHieigh = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    //导航栏添加搜索栏
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    CZJNaviagtionBarView* _navibarView = [[CZJNaviagtionBarView alloc]initWithFrame:mainViewBounds AndTag:CZJViewTypeNaviBarView];
    _navibarView.delegate = self;
    [self.navigationController.navigationBar addSubview:_navibarView];
    
    //固定数据
    NSDictionary* menuNames = @{@"2000" : @"线下服务",
                               @"2001" : @"油品化学品",
                               @"2003" : @"美容清洗",
                               @"2005" : @"车载电器",
                               @"2007" : @"汽车装饰",
                               @"2009" : @"汽车配件",
                               @"2011" : @"汽车改装",
                               @"2013" : @"安全自驾"
                           };
    
    for (NSString* key in menuNames)
    {
        rightMeun * meun=[[rightMeun alloc] init];
        meun.meunName=menuNames[key];
        meun.ID = key;
        [lis addObject:meun];
    }
    //数组升序排序
    [lis sortUsingComparator:^NSComparisonResult(rightMeun* obj1, rightMeun* obj2) {
        if (obj1.ID > obj2.ID)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (obj1.ID < obj2.ID) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    _multiView=[[MultilevelMenu alloc] initWithFrame:CGRectMake(0, NavigationBar_HEIGHT + statusbarHieigh, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT-NavigationBar_HEIGHT - tabbarHeight - statusbarHieigh) WithData:lis withSelectIndex:^(NSInteger left, NSInteger right,rightMeun* info) {
        DLog(@"点击的 菜单%@",info.meunName);
    }];
    _multiView.isRecordLastScroll=YES;
    [self.view addSubview:_multiView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
