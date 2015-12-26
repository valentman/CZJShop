//
//  CZJGoodsListFilterController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsListFilterController.h"
#import "CZJCarBrandChooseController.h"
#import "CZJSerFilterTypeChooseCell.h"
#import "CZJGoodsListFilterSubController.h"
#import "CZJBaseDataManager.h"
#import "CZJCarForm.h"


@interface CZJGoodsListFilterController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJGoodsListFilterSubControllerDelegate
>
{
    NSMutableDictionary* goodsListFilterPostParams;
}
@property (nonatomic, copy) MGBasicBlock basicBlock;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NSArray *conditionKeys;
@property (nonatomic, strong) NSArray* brandAndPriceArys;
@property (nonatomic, strong) NSMutableArray* filterConditionArys;
@property (nonatomic, strong) NSMutableArray* selectedConditionArys;

@end

@implementation CZJGoodsListFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"筛选";
    self.arrTitle = @[@"仅看有货", @"促销", @"新品"];
    goodsListFilterPostParams = [NSMutableDictionary dictionary];
    _brandAndPriceArys = @[@{@"name":@"品牌"},@{ @"name":@"价格"}];
    _filterConditionArys  = [NSMutableArray array];
    _selectedConditionArys = [NSMutableArray array];
    [self initViewsAndButtons];
    [self getGoodsFilterListFromServer];
}

- (void)initViewsAndButtons
{
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:@"ChooseCartype" object:nil];
}

- (void)refreshTableView:(id)sender
{
    [self.tableView reloadData];
}

- (void)getGoodsFilterListFromServer
{
    [goodsListFilterPostParams setObject:self.typeId forKey:@"typeId"];
    CZJSuccessBlock successBlock = ^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        [self.filterConditionArys removeAllObjects];
        [self.filterConditionArys addObjectsFromArray:_brandAndPriceArys];
        [self.filterConditionArys addObjectsFromArray:[dict valueForKey:@"msg"]];
        
        DLog(@"%@", [self.filterConditionArys description]);
        
        for (id obj in self.filterConditionArys)
        {
            NSMutableDictionary* dict = [@{[obj valueForKey:@"name"]:[NSMutableArray array]} mutableCopy];
            [self.selectedConditionArys addObject:dict];
        }
        [self.tableView reloadData];
    };
    
    [CZJBaseDataInstance loadGoodsFilterTypes:goodsListFilterPostParams
                                      success:successBlock
                                         fail:^{}];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (0 == section)
    {
        return 2;
    }
    if (1 == section)
    {
        return _filterConditionArys.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row) {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell0"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"选择车型";
            cell.detailTextLabel.text = [USER_DEFAULT valueForKey:kUserDefaultChoosedCarType];
            cell.detailTextLabel.textColor = [UIColor redColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            return cell;
        }
        if (1 == indexPath.row) {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setButtonDatas:self.arrTitle WithType:kCZJSerFilterTypeChooseCellTypeGoods];
            return cell;
        }
    }
    if (1 == indexPath.section)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell2"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString* categoryname = [[self.selectedConditionArys[indexPath.row] allKeys]firstObject];
        cell.textLabel.text = categoryname;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        NSMutableString* detailContent = [[NSMutableString alloc]init];
        NSMutableArray* obj =[self.selectedConditionArys[indexPath.row] valueForKey:categoryname];
        if (obj.count == 0) {
            detailContent = [@"全部" mutableCopy];
        }
        else
        {
            NSArray* conditions = [self.selectedConditionArys[indexPath.row] valueForKey:categoryname];
            for (NSDictionary* dict in conditions) {
                NSString* subName;
                if ([categoryname isEqualToString:@"品牌"] ||
                    [categoryname isEqualToString:@"价格"])
                {
                    subName = [dict valueForKey:@"name"];
                }
                else
                {
                    subName = [dict valueForKey:@"value"];
                }
                [detailContent appendString:subName];
                if (![dict isEqualToDictionary:[conditions lastObject]]) {
                    [detailContent appendString:@"、"];
                }
            }
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
        cell.detailTextLabel.text = detailContent;
        return cell;
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
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (1 == indexPath.row)
        {

            return  55;
        }
    }
    if (1 == indexPath.section)
    {

        return 44;

    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section && 0 == indexPath.row)
    {
        CZJCarBrandChooseController *svc = [[CZJCarBrandChooseController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    }
    if (1 == indexPath.section)
    {
        CZJGoodsListFilterSubController *svc = [[CZJGoodsListFilterSubController alloc] init];
        svc.typeId = self.typeId;
        svc.delegate = self;
        svc.subFilterName = [_filterConditionArys[indexPath.row] valueForKey:@"name"];
        svc.selectdCondictionArys = [NSMutableArray array];
        
        NSArray* currentAry = [self.selectedConditionArys[indexPath.row] valueForKey:svc.subFilterName];
        if (currentAry.count > 0) {
            [svc.selectdCondictionArys setArray:currentAry];
        }
        
        if (![svc.subFilterName isEqualToString:@"品牌"] &&
            ![svc.subFilterName isEqualToString:@"价格"])
        {
            svc.subFilterArys = [_filterConditionArys[indexPath.row] valueForKey:@"items"];
        }
        [self.navigationController pushViewController:svc animated:YES];
    }
}


#pragma mark- CZJGoodsListFilterSubControllerDelegate
- (void)sendChoosedDataBack:(id)data
{
    NSMutableDictionary* dictone = (NSMutableDictionary*)data;
    NSArray* allKeysOne = [dictone allKeys];
    NSString* nameChoose = [allKeysOne firstObject];
    for (id dict in self.selectedConditionArys)
    {
        NSMutableDictionary* dicts = (NSMutableDictionary*)dict;
        NSArray* allkeys = [dicts allKeys];
        NSString* nameOne = [allkeys firstObject];
        if ([nameChoose isEqualToString:nameOne]) {
            [dict setObject:[dictone objectForKey:nameChoose] forKey:nameOne];
            break;
        }
    }
    [self.tableView reloadData];
}

@end
