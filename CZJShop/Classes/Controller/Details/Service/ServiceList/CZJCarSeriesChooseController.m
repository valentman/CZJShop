//
//  CZJCarSeriesChooseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarSeriesChooseController.h"
#import "CZJBaseDataManager.h"
#import "CZJCarForm.h"
#import "CZJCarModelChooseController.h"
#define CarSesCellIdentifierID  @"CarSesCellIdentifierID"

@interface CZJCarSeriesChooseController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *curCarBrandLogo;
@property (nonatomic, strong) UILabel* curCarBrandName;
@end

@implementation CZJCarSeriesChooseController
@synthesize curCarBrandLogo = _curCarBrandLogo;
@synthesize curCarBrandName = _curCarBrandName;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择车系";
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    [self initTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [CZJBaseDataInstance loadCarSeriesWithBrandId:self.carBrand.brandId BrandName:self.carBrand.name Success:^(){
        [self initData];
        [self.tableView reloadData];
    } fail:^(){
        
    }];
}

- (void)initData
{
    _carSes = [[CZJBaseDataInstance carForm] carSeries];
    _keys = [_carSes allKeys];
}


- (void)initTableView
{
    NSInteger width = PJ_SCREEN_WIDTH - (CZJCarListTypeFilter == _carlistType ? kMGLeftSpace  : 0);

    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, StatusBar_HEIGHT + NavigationBar_HEIGHT, PJ_SCREEN_WIDTH, 64)];
    [self.topView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.topView];
    
    _curCarBrandLogo = [[UIImageView alloc]initWithFrame:CGRectMake(14,StatusBar_HEIGHT + NavigationBar_HEIGHT + 5, 60 , 50)];
    [self.view addSubview:_curCarBrandLogo];
    
    _curCarBrandName = [[UILabel alloc]initWithFrame:CGRectMake(80,StatusBar_HEIGHT + NavigationBar_HEIGHT + 20, 200 , 21)];
    _curCarBrandName.textColor = [UIColor grayColor];
    _curCarBrandName.font = [UIFont systemFontOfSize:16];
    _curCarBrandName.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_curCarBrandName];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 64, width, PJ_SCREEN_HEIGHT - 128)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    
    [_curCarBrandLogo sd_setImageWithURL:[NSURL URLWithString:self.carBrand.icon]
                        placeholderImage:[UIImage imageNamed:@"default_icon_car"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                   
                               }];
    _curCarBrandName.text = self.carBrand.name;
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
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    return [sess count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CarSesCellIdentifierID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CarSesCellIdentifierID];
        UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 16, PJ_SCREEN_WIDTH - 75, 18)];
        [cell addSubview:nameLabel];
        nameLabel.font = SYSTEMFONT(14);
        [nameLabel setTag:1999];
        nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    CarSeriesForm* obj = [sess objectAtIndex:indexPath.row];
    
    ((UILabel*)VIEWWITHTAG(cell, 1999)).text = obj.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    CarSeriesForm* obj = [sess objectAtIndex:indexPath.row];
    _currentSelect = obj;
    
    [CZJBaseDataInstance setCarSerialForm:obj];
    
    CZJCarModelChooseController *svc = [[CZJCarModelChooseController alloc] initWithType:_carlistType];
    svc.carSeries = _currentSelect;
    svc.carBrand = _carBrand;
    [self.navigationController pushViewController:svc animated:YES];

}

@end
