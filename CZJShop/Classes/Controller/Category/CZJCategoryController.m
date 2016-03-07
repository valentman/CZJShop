//
//  CZJCategoryController.m
//  CheZhiJian
//
//  Created by Joe.Pen on 11/11/15.
//  Copyright © 2015 chelifang. All rights reserved.
//

#import "CZJCategoryController.h"
#import "MultilevelMenu.h"
#import "CZJServiceListController.h"
#import "CZJGoodsListController.h"

@interface CZJCategoryController ()<CZJNaviagtionBarViewDelegate>
@property (weak, nonatomic) IBOutlet MultilevelMenu *multiView;
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *cateNaviBarView;
@property (strong, nonatomic) NSString* serviceTypeId;
@property (strong, nonatomic) NSString* goodsTypeId;

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
    [self.cateNaviBarView initWithFrame:mainViewBounds AndType:CZJNaviBarViewTypeCategory].delegate = self;
    

    DLog(@"height:%f",self.view.frame.size.height);
    
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
    
    CGRect multiRect;
    if (!_viewFromWhere)
    {
        multiRect = CGRectMake(0, StatusBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - Tabbar_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) ;
    }
    else
    {
        multiRect = CGRectMake(0, StatusBar_HEIGHT, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) ;
    }
    
    
    [self.multiView initWithFrame:multiRect WithData:lis withSelectIndex:^(NSInteger left, NSInteger right,rightMeun* info) {
        
        if (-1 == right)
        {//广告栏
            CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
            webView.cur_url = (NSString*)info;
            [self.navigationController pushViewController:webView animated:YES];
        }
        else
        {//Item
            if ([info.ID hasPrefix:@"10"])
            {
                _serviceTypeId = info.ID;
                [self performSegueWithIdentifier:@"segueToServiceList" sender:self];
            }
            else
            {
                _goodsTypeId = info.ID;
                [self performSegueWithIdentifier:@"segueToGoodsList" sender:self];
            }
        }
        
    }].isRecordLastScroll=YES;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.naviBarView refreshShopBadgeLabel];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToServiceList"])
    {
        CZJServiceListController* detailInfo = segue.destinationViewController;
        detailInfo.title = @"";
        detailInfo.navTitleName = @"";
        detailInfo.typeId = _serviceTypeId;
        
    }
    if ([segue.identifier isEqualToString:@"segueToGoodsList"])
    {
        CZJGoodsListController* detailInfo = segue.destinationViewController;
        detailInfo.typeId = _goodsTypeId;
    }
}


#pragma mark- CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(id)sender
{
    DLog(@"category");
}

@end
