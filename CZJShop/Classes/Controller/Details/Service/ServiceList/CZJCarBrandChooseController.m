//
//  CZJSerFilterChooseCar.m
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarBrandChooseController.h"
#import "CZJBaseDataManager.h"
#import "CZJCarForm.h"
#import "UIImageView+WebCache.h"
#import "CZJCarSeriesChooseController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"

static NSString *CarListCellIdentifierID = @"CarListCellIdentifierID";
@interface CZJCarBrandChooseController ()<UITableViewDelegate,UITableViewDataSource,SKSTableViewDelegate>
{
    NSMutableDictionary* _carBrands;
    NSMutableArray* _haveCars;
    NSArray * _keys;
    id _currentSelect;
}
@property (nonatomic, strong) SKSTableView *tableView;
@end

@implementation CZJCarBrandChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择车辆";
    [self initData];
    [self initTableView];
}

- (void)initData
{
    _carBrands = [[CZJBaseDataInstance carForm]carBrandsForms];
    _haveCars = [[CZJBaseDataInstance carForm]haveCarsForms];
    
    _keys = [_carBrands allKeys];
    NSArray *resultArray = [_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    _keys = resultArray;
    
}


- (void)initTableView
{
    NSInteger width = PJ_SCREEN_WIDTH - (CZJCarListTypeFilter == _carlistType ? kMGLeftSpace  : 0);
    self.tableView = [[SKSTableView alloc] initWithFrame:CGRectMake(0,64, width, PJ_SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    [self.view addSubview:self.tableView];
    
    UIView* topView = [[UIView alloc]initWithFrame:CGRectMake(0,-20, PJ_SCREEN_WIDTH, 64)];
    [self.view addSubview:topView];
    topView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,80)];
    self.tableView.tableFooterView = v;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_keys count] + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section)
    {
        if (CZJCarListTypeFilter == _carlistType)
        {
            return 1;
        }
        else if (CZJCarListTypeGeneral == _carlistType)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    else if (1 == section)
    {
        return 1;
    }
    else
    {
        NSString* tmp_key = [_keys objectAtIndex:(section- 2)];
        NSArray*  brands = [_carBrands objectForKey:tmp_key];
        UIView* headerview = [tableView headerViewForSection:(section - 2)];
        [headerview setBackgroundColor:[UIColor whiteColor]];
        return [brands count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        SKSTableViewCell* cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SKStableCell"];
        cell.textLabel.text = @"已有车辆";
        cell.expandable = NO;
        if (_haveCars.count > 0)
        {
            cell.detailTextLabel.text = ((HaveCarsForm*)_haveCars[0]).name;
            cell.detailTextLabel.textColor  = [UIColor redColor];
            cell.expandable = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (1 == indexPath.section)
    {
        SKSTableViewCell* cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hotBrandCell"];
        cell.expandable = NO;
        return cell;
    }
    else
    {
        SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CarListCellIdentifierID];
        if (!cell) {
            cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CarListCellIdentifierID];
        }
        NSString* tmp_key = [_keys objectAtIndex:(indexPath.section - 2)];
        NSArray*  brands = [_carBrands objectForKey:tmp_key];
        CarBrandsForm* obj = [brands objectAtIndex:indexPath.row];
        
        cell.textLabel.text = obj.name;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:obj.icon]
                          placeholderImage:[UIImage imageNamed:@"default_icon_car"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                     
                                 }];
        cell.expandable = NO;
        return cell;
    }
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (0 == section || 1 == section)
    {
        return nil;
    }
    NSString *sectionName = [_keys objectAtIndex:(section - 2)];
    return sectionName;
}




#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (CZJCarListTypeFilter == _carlistType)
        {
            return 44;
        }
        else if (CZJCarListTypeGeneral == _carlistType)
        {
            return 0;
        }
        else
        {
            return 44;
        }
    }
    else if (1 == indexPath.section)
    {//热门车辆的排列
        return 0;
    }
    else
    {
        return 55;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0.001;
    }
    else if (1 == section)
    {
        return 44;
    }
    else
    {
        return 44;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFootInSection:(NSInteger)section
{
    return 15;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor grayColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section)
    {
        
    }
    else if (1 == indexPath.section)
    {
        
    }
    else
    {
        NSString* tmp_key = [_keys objectAtIndex:(indexPath.section - 2)];
        NSArray*  brands = [_carBrands objectForKey:tmp_key];
        CarBrandsForm* obj = [brands objectAtIndex:indexPath.row];
        _currentSelect = obj;
        [CZJBaseDataInstance setCarBrandForm:obj];
        CZJCarSeriesChooseController *svc = [[CZJCarSeriesChooseController alloc] initWithType:_carlistType];
        svc.carBrand = obj;
        [self.navigationController pushViewController:svc animated:YES];
    }
}



#pragma mark- SKSTableView
- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return _haveCars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%ld, %ld", indexPath.section, indexPath.row);
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    HaveCarsForm* form = (HaveCarsForm*)_haveCars[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",form.name];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:form.icon]
                      placeholderImage:[UIImage imageNamed:@"default_icon_car"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                 
                             }];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (0 == indexPath.row)
    {
        cell.textLabel.textColor  = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"%ld, %ld", indexPath.section, indexPath.row);
    [self.navigationController popToRootViewControllerAnimated:true];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChooseCartype" object:nil];
    [USER_DEFAULT setValue:((HaveCarsForm*)_haveCars[indexPath.row]).name forKey:kUserDefaultChoosedCarModelType];
    
}

@end
