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
    NSMutableArray* _filterConditionArys;
    NSMutableArray* _brandIDArys;
    NSMutableArray* _arrtrIDArys;
    NSString* startPrice;
    NSString* endPrice;
    NSArray* _arrTitle;
}
@property (nonatomic, copy) MGBasicBlock basicBlock;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CZJGoodsListFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFilterDatas];
    [self initViewsAndButtons];
    if (_selectedConditionArys.count == 0)
    {
        [self getGoodsFilterListFromServer];
    }
    else
    {
        _filterConditionArys = [_selectedConditionArys mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)initFilterDatas
{
    self.title = @"筛选";
    _arrTitle = @[@"推荐", @"促销", @"有货"];
    _filterConditionArys  = [NSMutableArray array];
    _brandIDArys = [NSMutableArray array];
    _arrtrIDArys = [NSMutableArray array];
    
    startPrice = @"";
    endPrice = @"";
    
    CZJFilterBrandForm* brandForm = [[CZJFilterBrandForm alloc]init];
    brandForm.name = @"品牌";
    CZJFilterPriceForm* priceForm = [[CZJFilterPriceForm alloc]init];
    priceForm.name = @"价格";
    [_filterConditionArys addObject:brandForm];
    [_filterConditionArys addObject:priceForm];
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.clipsToBounds = true;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:@"ChooseCartype" object:nil];
}

- (void)refreshTableView:(id)sender
{
    [self.tableView reloadData];
}

- (void)getGoodsFilterListFromServer
{
    NSDictionary* params = @{@"typeId" : self.typeId};
    CZJSuccessBlock successBlock = ^(id json) {
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        [_filterConditionArys addObjectsFromArray:[CZJFilterCategoryForm objectArrayWithKeyValuesArray:dict]];
        
        [self.tableView reloadData];
    };
    
    [CZJBaseDataInstance loadGoodsFilterTypes:params
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
        
        [_brandIDArys removeAllObjects];
        [_arrtrIDArys removeAllObjects];
        for (CZJFilterBaseForm* baseForm in _filterConditionArys)
        {
            CZJFilterBaseForm* filterObject = (CZJFilterBaseForm*)baseForm;
            NSArray* conditions = filterObject.selectedItems;
            NSMutableArray* arrIDAry = [NSMutableArray array];
            for (id object in conditions) {
                if ([object isKindOfClass:[CZJFilterBrandItemForm class]])
                {//品牌
                    [_brandIDArys addObject:((CZJFilterBrandItemForm*)object).brandId];
                }
                if ([object isKindOfClass:[CZJFilterPriceItemForm class]])
                {//价格
                    startPrice = ((CZJFilterPriceItemForm*)object).startPrice;
                    endPrice = ((CZJFilterPriceItemForm*)object).endPrice;
                }
                if ([object isKindOfClass:[CZJFilterCategoryItemForm class]])
                {//其他动态改变的筛选条件
                    [arrIDAry addObject:((CZJFilterCategoryItemForm*)object).valueId];
                }
            }
            
            if ([filterObject isKindOfClass:[CZJFilterCategoryForm class]])
            {
                NSDictionary* attrIDDict = @{@"attrId" : ((CZJFilterCategoryForm*)filterObject).attrId,
                                             @"valueIds": arrIDAry};
                [_arrtrIDArys addObject:attrIDDict];
            }
        }
        
        [USER_DEFAULT setValue:[_brandIDArys componentsJoinedByString:@","] forKey:kUserDefaultChoosedBrandID];
        [USER_DEFAULT setValue:startPrice forKey:kUserDefaultStartPrice];
        [USER_DEFAULT setValue:endPrice forKey:kUserDefaultEndPrice];
        
        [self.delegate chooseGoodFilterOk:_filterConditionArys andData:_arrtrIDArys];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (1 == section)
    {
        return 2;
    }
    if (2 == section)
    {
        return _filterConditionArys.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section)
    {//选择车型和商品类型选择
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell0"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"选择车型";
        cell.textLabel.font = SYSTEMFONT(14);
        
        cell.detailTextLabel.text = [USER_DEFAULT valueForKey:kUserDefaultChoosedCarModelType];
        cell.detailTextLabel.textColor = CZJREDCOLOR;
        cell.detailTextLabel.font = SYSTEMFONT(14);
        return cell;
    }
    
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell0"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"类别";
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            return cell;
        }
        if (1 == indexPath.row) {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setButtonDatas:_arrTitle WithType:kCZJSerFilterTypeChooseCellTypeGoods];
            return cell;
        }
    }
    if (2 == indexPath.section)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell2"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CZJFilterBaseForm* filterObject = _filterConditionArys[indexPath.row];
        
        //筛选条件名称
        NSString* categoryname = filterObject.name;
        cell.textLabel.text = categoryname;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = SYSTEMFONT(14);
        
        //筛选条件
        NSString* detailContent = [[NSMutableString alloc]init];
        NSMutableArray* obj = filterObject.selectedItems;
        if (obj.count == 0) {
            detailContent = [@"全部" mutableCopy];
        }
        else
        {
            NSArray* conditions = filterObject.selectedItems;
            NSMutableArray* conditionNames = [NSMutableArray array];
            for (id object in conditions) {
                if ([object isKindOfClass:[CZJFilterBrandItemForm class]])
                {//品牌
                    [conditionNames addObject: ((CZJFilterBrandItemForm*)object).name];
                }
                if ([object isKindOfClass:[CZJFilterPriceItemForm class]])
                {//价格
                    [conditionNames addObject: ((CZJFilterPriceItemForm*)object).name];
                }
                if ([object isKindOfClass:[CZJFilterCategoryItemForm class]])
                {//其他动态改变的筛选条件
                    [conditionNames addObject:((CZJFilterCategoryItemForm*)object).value];
                }
                detailContent = [conditionNames componentsJoinedByString:@"、"];
            }
            cell.detailTextLabel.textColor = CZJREDCOLOR;
        }
        cell.detailTextLabel.text = detailContent;
        return cell;
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


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section ||
        2 == section)
    {
        return 10;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (1 == indexPath.row)
        {
            return  50;
        }
    }
    if (2 == indexPath.section ||
        0 == indexPath.section)
    {
        return 44;
    }
    if (3 == indexPath.section)
    {
        return 100;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section && 0 == indexPath.row)
    {
        CZJCarBrandChooseController *svc = [[CZJCarBrandChooseController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    }
    if (2 == indexPath.section)
    {
        CZJFilterBaseForm* touchedCategory = ((CZJFilterBaseForm*)_filterConditionArys[indexPath.row]);
        CZJGoodsListFilterSubController *svc = [[CZJGoodsListFilterSubController alloc] init];
        svc.typeId = self.typeId;
        svc.delegate = self;
        svc.subFilterName = touchedCategory.name;
        svc.selectdCondictionArys = [NSMutableArray array];
        
        NSArray* currentAry = touchedCategory.selectedItems;
        if (currentAry.count > 0) {
            //如果是品牌或是价格，
            [svc.selectdCondictionArys setArray:currentAry];
        }
        
        //非品牌和价格筛选项，须传相应筛选条件到下一个VC
        if (![svc.subFilterName isEqualToString:@"品牌"] &&
            ![svc.subFilterName isEqualToString:@"价格"])
        {
            svc.subFilterArys = ((CZJFilterCategoryForm*)touchedCategory).items;
        }
        [self.navigationController pushViewController:svc animated:YES];
    }
}


- (void)resetFilterConditioins
{
    for (CZJFilterBaseForm* baseForm in _filterConditionArys)
    {
        CZJFilterBaseForm* filterObject = (CZJFilterBaseForm*)baseForm;
        [filterObject.selectedItems removeAllObjects];
        [self.tableView reloadData];
    }
}


#pragma mark- CZJGoodsListFilterSubControllerDelegate
- (void)sendChoosedDataBack:(id)data
{
    NSMutableDictionary* dictone = (NSMutableDictionary*)data;
    NSArray* allKeysOne = [dictone allKeys];
    NSString* nameChoose = [allKeysOne firstObject];
    for (CZJFilterBaseForm* baseForm in _filterConditionArys)
    {
        if ([baseForm.name isEqualToString:nameChoose])
        {
            baseForm.selectedItems = [dictone valueForKey:nameChoose];
            break;
        }
    }
    [self.tableView reloadData];
}

@end
