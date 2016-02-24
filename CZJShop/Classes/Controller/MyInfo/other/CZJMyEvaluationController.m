//
//  CZJMyEvaluationController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyEvaluationController.h"
#import "CZJBaseDataManager.h"
@interface CZJMyEvaluationController ()
<
UITableViewDataSource,
UITableViewDelegate
>
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyEvaluationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self getMyEvalutionDataFromServer];
}

- (void)initTableView
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CLEARCOLOR;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCommentCell",
                         @"CZJOrderCarCheckCell",
                         @"CZJOrderBuildingImagesCell",
                         @"CZJOrderBuildCarCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getMyEvalutionDataFromServer
{
    NSDictionary* param = @{@"page":@"1"};
    [CZJBaseDataInstance generalPost:param success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    } andServerAPI:kCZJServerAPIMyEvalutions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
