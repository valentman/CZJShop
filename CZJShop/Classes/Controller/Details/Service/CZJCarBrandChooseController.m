//
//  CZJSerFilterChooseCar.m
//  CZJShop
//
//  Created by Joe.Pen on 12/10/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarBrandChooseController.h"
#import "CZJHomeViewManager.h"
#import "CZJCarForm.h"
#import "UIImageView+WebCache.h"
#import "CZJCarSeriesChooseController.h"

static NSString *CarListCellIdentifierID = @"CarListCellIdentifierID";
@interface CZJCarBrandChooseController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableDictionary* _carBrands;
    NSArray * _keys;
    id _currentSelect;
}
@property (nonatomic, strong) UITableView *tableView;
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
    _carBrands = [[CZJHomeViewInstance carForm]carBrandsForms];
    _keys = [_carBrands allKeys];
    NSArray *resultArray = [_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    _keys = resultArray;
    
}


- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, PJ_SCREEN_WIDTH-kMGLeftSpace, PJ_SCREEN_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* tmp_key = [_keys objectAtIndex:section];
    NSArray*  brands = [_carBrands objectForKey:tmp_key];
    return [brands count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CarListCellIdentifierID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CarListCellIdentifierID];
    }
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  brands = [_carBrands objectForKey:tmp_key];
    CarBrandsForm* obj = [brands objectAtIndex:indexPath.row];

    cell.textLabel.text = obj.name;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:obj.icon]
                      placeholderImage:[UIImage imageNamed:@"default_icon_car.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                 
                             }];
    return cell;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [_keys objectAtIndex:section];
    return sectionName;
}


#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  brands = [_carBrands objectForKey:tmp_key];
    CarBrandsForm* obj = [brands objectAtIndex:indexPath.row];
    _currentSelect = obj;
    [CZJHomeViewInstance loadCarSeriesWithBrandId:obj.brandId BrandName:obj.name Success:^(){
        CZJCarSeriesChooseController *svc = [[CZJCarSeriesChooseController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    } fail:^(){
        
    }];
}




@end
