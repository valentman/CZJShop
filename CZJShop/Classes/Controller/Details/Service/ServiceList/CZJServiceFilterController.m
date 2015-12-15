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
@property (nonatomic, copy) MGBasicBlock basicBlock;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NSMutableArray* aviableServiceAry;
@end

@implementation CZJServiceFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"筛选";
    
    NSArray* tmpary = [CZJBaseDataInstance homeForm].serviceForms;
    self.aviableServiceAry = [NSMutableArray array];
    //只显示开了的服务
    for (id obj in tmpary)
    {
        ServiceForm* form = (ServiceForm*)obj;
        if (form.open)
        {
            [self.aviableServiceAry addObject:form];
        }
    }
    
    
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightBtn addTarget:self action:@selector(navBackBarAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setTag:1001];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem setTag:1001];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.clipsToBounds = true;
    [self.view addSubview:self.tableView];
    
    self.arrTitle = @[@"到店服务", @"上门服务"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:@"ChooseCartype" object:nil];
}


- (void)refreshTableView:(id)sender
{
    [self.tableView reloadData];
}

- (void)setCancleBarItemHandle:(MGBasicBlock)basicBlock{
    
    self.basicBlock = basicBlock;
}

- (void)cancelAction:(UIBarButtonItem *)bar{
    
    if(self.basicBlock)self.basicBlock();
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ChooseCartype" object:nil];
    
}
- (void)navBackBarAction:(UIBarButtonItem *)bar{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self cancelAction:bar];
        [self.delegate chooseFilterOK];
    }
}


#pragma mark- UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section)
    {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell0"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"选择车型";
        cell.detailTextLabel.text = [USER_DEFAULT valueForKey:kUserDefaultChoosedCarType];
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        return cell;
    }
    if (1 == indexPath.section)
    {
        if (0==indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"类别";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
           
            [cell setButtonDatas:self.aviableServiceAry WithType:kCZJSerFilterTypeChooseCellTypeService];
            return cell;
        }
    }
    if (2 == indexPath.section)
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
    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return 10;
    }
    return 0;
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
            int col = ceilf(self.aviableServiceAry.count / 3.0) ;
            return  col * 55;
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
            return 55;
        }
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
