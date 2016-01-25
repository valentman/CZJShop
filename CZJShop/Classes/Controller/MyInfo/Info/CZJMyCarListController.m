//
//  CZJMyCarListController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyCarListController.h"
#import "CZJMyCarListCell.h"
#import "UIImageView+WebCache.h"
#import "CZJBaseDataManager.h"
#import "CZJCarBrandChooseController.h"


@interface CZJMyCarListController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* carList;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)addMyCarAction:(id)sender;
@end

@implementation CZJMyCarListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getCarListFromServer];
    // Do any additional setup after loading the view.
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    self.navigationController.toolbar.translucent = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.tableHeaderView = [[UIView alloc]init];
    UINib* nib = [UINib nibWithNibName:@"CZJMyCarListCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:@"CZJMyCarListCell"];
    self.myTableView.hidden = YES;
    self.myTableView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
}


- (void)getCarListFromServer
{
    [CZJBaseDataInstance getMyCarList:nil Success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        carList = [dict valueForKey:@"msg"];
        if ([carList isKindOfClass:[NSArray class]])
        {
            if (carList.count > 0) {
                self.myTableView.hidden = NO;
                self.myTableView.delegate = self;
                self.myTableView.dataSource = self;
                [self.myTableView reloadData];
            }
        }

    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([carList isKindOfClass:[NSArray class]])
    {
        return carList.count;
    }
    else
    {
        return 0;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCarListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyCarListCell" forIndexPath:indexPath];
    NSDictionary* dict = carList[indexPath.section];
    
    [cell.brandImg sd_setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"logo"]] placeholderImage:IMAGENAMED(@"default_icon_car")];
    NSString* carName = [NSString stringWithFormat:@"%@ %@ %@%@%@",[dict valueForKey:@"brandName"], [dict valueForKey:@"seriesName"],[dict valueForKey:@"prov"],[dict valueForKey:@"number"],[dict valueForKey:@"numberPlate"]];
    cell.carNameLabel.text = carName;
    cell.carModelLabel.text = [dict valueForKey:@"modelName"];
    cell.setDefaultBtn.selected = [[dict valueForKey:@"dftFlag"] boolValue];
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (IBAction)addMyCarAction:(id)sender
{
    CZJCarBrandChooseController *svc = [[CZJCarBrandChooseController alloc] initWithType:CZJCarListTypeGeneral];
    [self.navigationController pushViewController:svc animated:YES];
}
@end
