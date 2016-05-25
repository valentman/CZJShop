//
//  CZJServiceFilterController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceFilterController.h"
#import "CZJCarBrandChooseController.h"
#import "CZJSerFilterTypeChooseCell.h"
#import "CZJBaseDataManager.h"
#import "CZJCarForm.h"
#import "HomeForm.h"

@interface CZJServiceFilterController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* _aviableServiceAry;
}
@property (nonatomic, copy) MGBasicBlock basicBlock;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NSMutableArray* aviableServiceAry;
@end

@implementation CZJServiceFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initServiceFilterDatas];
}

- (void)initServiceFilterDatas
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [CZJBaseDataInstance generalPost:nil success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        _aviableServiceAry = [[ServiceForm objectArrayWithKeyValuesArray:[dict valueForKey:@"msg"]] mutableCopy];
        [CZJUtils performBlock:^{
            [weakSelf.tableView reloadData];
        } afterDelay:0.5];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPILoadServiceTypes];
}

- (void)initViews
{
    self.title = @"筛选";
    
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightBtn addTarget:self action:@selector(navBackBarAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setTag:1001];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    if (IS_IOS9)
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceBar.width = 50;
        self.navigationItem.rightBarButtonItems = @[spaceBar,rightItem];
    }
    [rightItem setTag:1001];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.clipsToBounds = true;
    self.tableView.bounces = YES;
    self.arrTitle = @[@"到店服务", @"上门服务"];
    self.automaticallyAdjustsScrollViewInsets =  NO;
    [self.view addSubview:self.tableView];
    
    [self.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(cancelAction:)]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:@"ChooseCartype" object:nil];
}

- (void)removeServiceFilterNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ChooseCartype" object:nil];
}

- (void)refreshTableView:(id)sender
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setCancleBarItemHandle:(MGBasicBlock)basicBlock{
    
    self.basicBlock = basicBlock;
}

- (void)cancelAction:(UIBarButtonItem *)bar{
    if(self.basicBlock)self.basicBlock();
}

- (void)navBackBarAction:(UIBarButtonItem *)bar{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self cancelAction:bar];
        [self.delegate chooseFilterOK:nil];
    }
}


#pragma mark- UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (0 == section)
    {
        return 1;
    }
    if (1 == section)
    {
        return 2;
    }
    if (2 == section)
    {
        return 2;
    }
    if (3 == section)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section)
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell0"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"选择车型";
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        cell.detailTextLabel.text = [USER_DEFAULT valueForKey:kUserDefaultChoosedCarModelType];
        cell.detailTextLabel.textColor = CZJREDCOLOR;
        cell.detailTextLabel.font = SYSTEMFONT(14);
        
        return cell;
    }
    if (1 == indexPath.section)
    {
        if (0==indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"服务方式";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell4"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setButtonDatas:[self.arrTitle mutableCopy] WithType:kCZJSerFilterTypeChooseCellTypeGoWhere];
            return cell;
        }
    }
    if (2 == indexPath.section)
    {
        if (0==indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"服务类别";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.typeId = self.typeId;
            [cell setButtonDatas:_aviableServiceAry WithType:kCZJSerFilterTypeChooseCellTypeService];
            return cell;
        }
    }
    if (3 == indexPath.section)
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell5"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton* resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetBtn addTarget:self action:@selector(resetFilterConditioins) forControlEvents:UIControlEventTouchUpInside];
        resetBtn.frame = CGRectMake(0, 0, 85, 30);
        [resetBtn setPosition:CGPointMake((PJ_SCREEN_WIDTH - 50)*0.5, cell.frame.size.height*0.5) atAnchorPoint:CGPointMiddle];
        [resetBtn setImage:[UIImage imageNamed:@"shaixuan_btn_refresh@3x"] forState:UIControlStateNormal];
        [cell addSubview:resetBtn];
        return cell;
    }
    return nil;
}

- (void)resetFilterConditioins
{
    [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelType];
//    [USER_DEFAULT setValue:@"" forKey:kUserDefaultServicePlace];
    [USER_DEFAULT setValue:self.typeId forKey:kUserDefaultServiceTypeID];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section ||
        3 == section) {
        return 0;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return 46;
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (1 == indexPath.row)
        {
            return 55;
        }
    }
    if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (1 == indexPath.row)
        {
            int col = ceilf(self.aviableServiceAry.count / 3.0) ;
            return  col * 50;
        }
    }
    if (3 == indexPath.section)
    {
        return 50;
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0)
    {
        CZJCarBrandChooseController *svc = [[CZJCarBrandChooseController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    }
}

@end
