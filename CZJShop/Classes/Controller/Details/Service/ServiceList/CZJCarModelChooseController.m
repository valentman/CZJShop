//
//  CZJCarModelChooseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarModelChooseController.h"
#import "CZJBaseDataManager.h"
#import "UIImageView+WebCache.h"
static NSString *CarModelCellIdentifierID = @"CarModelCellIdentifierID";


@interface CZJCarModelChooseController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *curCarBrandLogo;
@property (nonatomic, strong) UIImageView *nextArrowImg;
@property (nonatomic, strong) UILabel* curCarBrandName;
@property (nonatomic, strong) UILabel* curCarSerieName;

@end

@implementation CZJCarModelChooseController
@synthesize carSeries = _carSeries;
@synthesize carBrand = _carBrand;
@synthesize curCarBrandName = _curCarBrandName;
@synthesize curCarSerieName = _curCarSerieName;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择车型";
    [self initTableView];
    [CZJBaseDataInstance loadCarModelSeriesId:[NSString stringWithFormat:@"%d", self.carSeries.seriesId] Success:^()
     {
         [self initData];
     } fail:^(){}];
}

- (void)initData
{
    _carModels = [[CZJBaseDataInstance carForm] carModels];
    [self.tableView reloadData];
}


- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, PJ_SCREEN_WIDTH-kMGLeftSpace, PJ_SCREEN_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,80)];
    self.tableView.tableFooterView = v;
    [self.view addSubview:self.tableView];
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, 60)];
    [self.topView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.topView];
    
    //品牌logo
    _curCarBrandLogo = [[UIImageView alloc]initWithFrame:CGRectMake(14,StatusBar_HEIGHT + NavigationBar_HEIGHT + 5, 60 , 50)];
    [self.view addSubview:_curCarBrandLogo];
    [_curCarBrandLogo sd_setImageWithURL:[NSURL URLWithString:self.carBrand.icon]
                        placeholderImage:[UIImage imageNamed:@"default_icon_car"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                   
                               }];
    
    //品牌名
    _curCarBrandName = [[UILabel alloc]initWithFrame:CGRectMake(80,StatusBar_HEIGHT + NavigationBar_HEIGHT + 20, 200 , 21)];
    _curCarBrandName.textColor = [UIColor grayColor];
    _curCarBrandName.font = [UIFont systemFontOfSize:16];
    _curCarBrandName.textAlignment = NSTextAlignmentLeft;
    _curCarBrandName.text = _carBrand.name;
    [self.view addSubview:_curCarBrandName];
    
    //箭头
    CGSize titleSize = [CZJUtils calculateTitleSizeWithString:self.carBrand.name AndFontSize:16];
    _nextArrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(80 + titleSize.width+ 5, StatusBar_HEIGHT + NavigationBar_HEIGHT + 26, 5, 10)];
    [_nextArrowImg setImage:[UIImage imageNamed:@"all_arrow_next"]];
    [self.view addSubview:_nextArrowImg];
    
    //车系名
    _curCarSerieName = [[UILabel alloc]initWithFrame:CGRectMake(80 + titleSize.width+ 15, StatusBar_HEIGHT + NavigationBar_HEIGHT + 20, 200 , 21)];
    _curCarSerieName.textColor = [UIColor grayColor];
    _curCarSerieName.font = [UIFont systemFontOfSize:16];
    _curCarSerieName.textAlignment = NSTextAlignmentLeft;
    _curCarSerieName.text = _carSeries.name;
    [self.view addSubview:_curCarSerieName];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_carModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CarModelCellIdentifierID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CarModelCellIdentifierID];
    }
    CarModelForm* obj = [_carModels objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentSelect = [_carModels objectAtIndex:indexPath.row];
    [USER_DEFAULT setValue:_currentSelect.name forKey:kUserDefaultChoosedCarType];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChooseCartype" object:nil];
}

@end
