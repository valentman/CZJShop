//
//  CZJCarSeriesChooseController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarSeriesChooseController.h"
#import "CZJHomeViewManager.h"
#import "CZJCarForm.h"
#import "UIImageView+WebCache.h"
#import "CZJCarModelChooseController.h"
#define CarSesCellIdentifierID  @"CarSesCellIdentifierID"

@interface CZJCarSeriesChooseController ()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CZJCarSeriesChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择车系";
    [self initData];
    [self initTableView];
    

}

- (void)initData
{
    _carSes = [[CZJHomeViewInstance carForm] carSeries];
    _keys = [_carSes allKeys];
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString* tmp_key = [_keys objectAtIndex:section];
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    return [sess count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CarSesCellIdentifierID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CarSesCellIdentifierID];
    }
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    CarSeriesForm* obj = [sess objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.name;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [_keys objectAtIndex:section];
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* tmp_key = [_keys objectAtIndex:indexPath.section];
    NSArray*  sess = [_carSes objectForKey:tmp_key];
    CarSeriesForm* obj = [sess objectAtIndex:indexPath.row];
    _currentSelect = obj;
    [CZJHomeViewInstance loadCarModelSeriesId:[NSString stringWithFormat:@"%d", obj.seriesId] Success:^()
    {
        CZJCarModelChooseController *svc = [[CZJCarModelChooseController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    } fail:^(){}];
}

@end
