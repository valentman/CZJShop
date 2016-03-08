//
//  CZJMyMessageCenterController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/21/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyMessageCenterController.h"

@interface CZJMyMessageCenterController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    BOOL isEdit;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyMessageCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    isEdit = NO;
    [CZJUtils customizeNavigationBarForTarget:self];
    //右按钮
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(PJ_SCREEN_WIDTH - 44 , 0 , 88 , 44 );
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    [rightBtn setTag:2999];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGRect tableRect = CGRectMake(0, 64 + 80, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT);
    self.myTableView = [[UITableView alloc]initWithFrame:tableRect style:UITableViewStylePlain];
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

- (void)edit:(id)sender
{
    isEdit = !isEdit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEdit || indexPath.row == 0)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //        CZJShoppingCartInfoForm *goodsList = [shoppingInfos objectAtIndex:indexPath.section];
        //        CZJShoppingGoodsInfoForm *model = [ goodsList.items objectAtIndex:indexPath.row -1];
        //        NSDictionary* params = @{@"storeItemPids" : model.storeItemPid};
        //        [CZJBaseDataInstance removeProductFromShoppingCart:params Success:^{
        //            [CZJBaseDataInstance loadShoppingCartCount:nil Success:nil fail:nil];
        //            model.isSelect=NO;
        //            [goodsList.items removeObjectAtIndex:indexPath.row - 1];
        //
        //            if (0 == goodsList.items.count ){
        //                [shoppingInfos removeObjectAtIndex:indexPath.section];
        //                [self.myTableView reloadData];
        //            }
        //            else
        //            {
        //                [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        //            }
        
//    } fail:^{
//        //删除失败
//    }];
}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
