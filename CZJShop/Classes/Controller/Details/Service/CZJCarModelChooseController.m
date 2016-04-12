//
//  CZJCarModelChooseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarModelChooseController.h"
#import "CZJHomeViewManager.h"
static NSString *CarModelCellIdentifierID = @"CarModelCellIdentifierID";


@interface CZJCarModelChooseController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CZJCarModelChooseController
@synthesize carSeries;
@synthesize carBrand;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择车型";
    [self initData];
    [self initTableView];
}

- (void)initData
{
    _carModels = [[CZJHomeViewInstance carForm] carModels];
    [self.tableView reloadData];
    
//    [_curCarBrandLogo sd_setImageWithURL:[NSURL URLWithString:self.carBrand.icon]
//                        placeholderImage:[UIImage imageNamed:@"default_iicon_ser.png"]
//                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//                                   
//                               }];
//    _curCarName.text = self.carBrand.name;
    
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
    
    return cell;
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
