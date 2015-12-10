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

@interface CZJCategoryController ()<CZJNaviagtionBarViewDelegate>
@property (weak, nonatomic) IBOutlet MultilevelMenu *multiView;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *naviBarView;
@end

@implementation CZJCategoryController
@synthesize multiView = _multiView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray * lis=[NSMutableArray arrayWithCapacity:0];
    
    
    id navigationBarAppearance = self.navigationController.navigationBar;
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"nav_bargound"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.navigationBar.shadowImage =[UIImage imageNamed:@"nav_bargound"];

    
    //导航栏添加搜索栏
    self.navigationController.navigationBarHidden = YES;
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    [self.naviBarView initWithFrame:mainViewBounds AndType:CZJViewTypeNaviBarViewCategory].delegate = self;
    [self.naviBarView setBackgroundColor:UIColorFromRGB(0xF3F4F6)];

    
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
    
    [self.multiView initWithFrame:CGRectMake(0, StatusBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - Tabbar_HEIGHT - StatusBar_HEIGHT) WithData:lis withSelectIndex:^(NSInteger left, NSInteger right,rightMeun* info) {
        DLog(@"点击的 菜单%@",info.meunName);
    }];
    _multiView.isRecordLastScroll=YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- CZJNaviBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    DLog(@"category");
}

@end
