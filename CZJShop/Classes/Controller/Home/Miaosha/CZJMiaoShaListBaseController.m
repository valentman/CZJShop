//
//  CZJMiaoShaListBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMiaoShaListBaseController.h"
#import "CZJMiaoShaControlCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMiaoShaListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* miaoShaAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMiaoShaListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getMiaoShaDataFromServer];
}

- (void)initViews
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT - 30 - 50) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJMiaoShaControlCell"];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getMiaoShaDataFromServer
{
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        NSArray* tmpAry = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
        miaoShaAry = [CZJMiaoShaCellForm objectArrayWithKeyValuesArray:tmpAry];
    } andServerAPI:kCZJServerAPIPGetSkillGoodsList];
    
    [self.myTableView reloadData];
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
    return miaoShaAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMiaoShaControlCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaControlCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117;
}
@end



@implementation CZJMiaoShaOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getMiaoShaDataFromServer];
    } afterDelay:0.5];
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"skillId":@"223"};
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMiaoShaTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getMiaoShaDataFromServer];
    } afterDelay:0.5];
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getMiaoShaDataFromServer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end



@implementation CZJMiaoShaThreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getMiaoShaDataFromServer];
    } afterDelay:0.5];
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getMiaoShaDataFromServer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJMiaoShaFourController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getMiaoShaDataFromServer];
    } afterDelay:0.5];
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMiaoShaFiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils performBlock:^{
        [self getMiaoShaDataFromServer];
    } afterDelay:0.5];
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"type":@"0", @"page":@"1", @"timeType":@"0"};
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end




