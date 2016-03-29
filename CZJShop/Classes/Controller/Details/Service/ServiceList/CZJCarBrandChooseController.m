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
#import "CZJCarSeriesChooseController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "CZJHotBrandViewCell.h"

static NSString *CarListCellIdentifierID = @"CarListCellIdentifierID";
@interface CZJCarBrandChooseController ()
<SKSTableViewDelegate>
{
    NSMutableDictionary* _carBrands;
    NSArray* _haveCars;
    NSArray* _hotBrands;
    NSArray* _keys;
    id _currentSelect;
}
@property (nonatomic, strong) SKSTableView *tableView;
@end

@implementation CZJCarBrandChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initData];
}

- (void)initTableView
{
    self.title = @"选择车辆";
    
    UIView* topView = [[UIView alloc]initWithFrame:CGRectMake(0,-20, PJ_SCREEN_WIDTH, 64)];
    [self.view addSubview:topView];
    topView.backgroundColor = CZJNAVIBARBGCOLOR;
    
    NSInteger width = PJ_SCREEN_WIDTH - (CZJCarListTypeFilter == _carlistType ? kMGLeftSpace  : 0);
    self.tableView = [[SKSTableView alloc] initWithFrame:CGRectMake(0, 64, width, PJ_SCREEN_HEIGHT)];
    self.tableView.clipsToBounds = NO;
    self.tableView.backgroundColor = CZJTableViewBGColor;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
}

- (void)initData
{
    _carBrands = [[CZJBaseDataInstance carForm]carBrandsForms];
    if (_carBrands.count == 0)
    {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        [CZJBaseDataInstance getCarBrandsList:^(id json) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dealWithCarData];
        }];
    }
    else
    {
        [self dealWithCarData];
    }
}


- (void)dealWithCarData
{
    _carBrands = [[CZJBaseDataInstance carForm]carBrandsForms];
    _haveCars = [[CZJBaseDataInstance carForm]haveCarsForms];
    _hotBrands = [[CZJBaseDataInstance carForm]hotBrands];
    _keys = [_carBrands allKeys];
    NSArray *resultArray = [_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    _keys = resultArray;
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DLog();
    return 2 + _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DLog(@"section:%ld",section)
    if (0 == section)
    {
        if (CZJCarListTypeFilter == _carlistType)
        {
//            return 1 ;
            return 0;
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
        return 2;
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

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return _haveCars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"section:%ld",indexPath.section);
    if (indexPath.section == 0)
    {
        SKSTableViewCell* cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SKStableCell"];
        cell.textLabel.text = @"已有车辆";
        if (_haveCars.count > 0)
        {
            cell.detailTextLabel.text = ((HaveCarsForm*)_haveCars[0]).brandName;
            cell.detailTextLabel.textColor  = CZJREDCOLOR;
            cell.detailTextLabel.font = SYSTEMFONT(14);
            [cell setExpandable:YES];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            SKSTableViewCell* cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hotBrandHeadCell"];
            cell.textLabel.text = @"热门品牌";
            cell.textLabel.textColor = LIGHTGRAYCOLOR;
            [cell.imageView setImage:IMAGENAMED(@"shaixuan_icon_hot")];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            SKSTableViewCell* cell = [[SKSTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"hotBrandCell"];
            for (int i = 0; i < _hotBrands.count; i++)
            {
                int divide = (iPhone5 || iPhone4) ? 4 : 5;
                CarBrandsForm* brandForm = _hotBrands[i];
                CGRect hotBrandRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(50, 55) index:i divide:divide];
                CZJHotBrandViewCell* hotCell = [CZJUtils getXibViewByName:@"CZJHotBrandViewCell"];
                hotCell.frame = hotBrandRect;
                [hotCell.brandImg sd_setImageWithURL:[NSURL URLWithString:brandForm.icon] placeholderImage:DefaultPlaceHolderImage];
                hotCell.brandName.text = brandForm.name;
                [hotCell.hotBrandBtn setTag:i];
                [hotCell.hotBrandBtn addTarget:self action:@selector(hotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:hotCell];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    HaveCarsForm* form = (HaveCarsForm*)_haveCars[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",form.brandName];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:form.logo]
                      placeholderImage:[UIImage imageNamed:@"default_icon_car"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                 
                             }];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (0 == indexPath.row)
    {
        cell.textLabel.textColor  = CZJREDCOLOR;
    }
    return cell;
}


#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (CZJCarListTypeFilter == _carlistType)
        {
            //return 44;
            return 0;
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
    {
        //热门车辆的排列
        if (0 == indexPath.row)
        {
            return 44;
        }
        else
        {//动态调整
            int divide = (iPhone5 || iPhone4) ? 4 : 5;
            NSInteger row = 0;
            if (_hotBrands.count > 0)
            {
                row = ceil(_hotBrands.count / divide);
            }
            return (65 + 10) * row;
        }
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
        return 0;
    }
    else if (1 == section)
    {
        return 10;
    }
    else
    {
        return 44;
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor grayColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section >= 2 )
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

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popToRootViewControllerAnimated:true];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChooseCartype" object:nil];
    [USER_DEFAULT setValue:((HaveCarsForm*)_haveCars[indexPath.row]).brandName forKey:kUserDefaultChoosedCarModelType];
    [USER_DEFAULT setValue:((HaveCarsForm*)_haveCars[indexPath.row]).modelId forKey:kUserDefaultChoosedCarModelID];
}


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


#pragma mark- 点击事件
- (void)hotBtnClick:(UIButton*)sender
{
    CarBrandsForm* obj = [_hotBrands objectAtIndex:sender.tag];
    _currentSelect = obj;
    [CZJBaseDataInstance setCarBrandForm:obj];
    CZJCarSeriesChooseController *svc = [[CZJCarSeriesChooseController alloc] initWithType:_carlistType];
    svc.carBrand = obj;
    [self.navigationController pushViewController:svc animated:YES];
}
@end
