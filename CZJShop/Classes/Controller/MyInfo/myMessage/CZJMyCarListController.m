//
//  CZJMyCarListController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyCarListController.h"
#import "CZJMyCarListCell.h"
#import "CZJBaseDataManager.h"
#import "CZJCarBrandChooseController.h"


@interface CZJMyCarListController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJMyCarListCellDelegate
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
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    
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
        DLog(@"%@", [dict description]);
        carList = [HaveCarsForm objectArrayWithKeyValuesArray:[[CZJUtils DataFromJson:json] valueForKey:@"msg"]];
        if (carList.count > 0) {
            [CZJUtils removeNoDataAlertViewFromTarget:self.view];
            self.myTableView.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
        }
        else
        {
            [self.myTableView reloadData];
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"您还没有爱车，去添加吧/(ToT)/~~"];
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
    cell.delegate = self;
    HaveCarsForm* carForm = carList[indexPath.section];
    cell.tag  = indexPath.section;
    [cell.brandImg sd_setImageWithURL:[NSURL URLWithString:carForm.logo] placeholderImage:DefaultPlaceHolderSquare];
    NSString* carName = [NSString stringWithFormat:@"%@ %@",carForm.brandName, carForm.seriesName];
    cell.carNameLabel.text = carName;
    cell.carModelLabel.text = carForm.modelName;
    cell.setDefaultBtn.selected = carForm.dftFlag;
    cell.carNumberPlate.text = [NSString stringWithFormat:@"%@%@-%@",carForm.prov,carForm.number,carForm.numberPlate];
    if (indexPath.section == (carList.count - 1))
        cell.separatorInset = HiddenCellSeparator;
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


#pragma mark -CZJMyCarListCellDelegate
- (void)deleteMyCarActionCallBack:(id)sender
{
    HaveCarsForm* carForm = carList[((UIButton*)sender).tag];
    __weak typeof(self) weakSelf = self;
    [self showCZJAlertView:@"确认删除此爱车么？" andConfirmHandler:^{
        [CZJBaseDataInstance removeMyCar:@{@"id" : carForm.haveCarID} Success:^(id json) {
            [CZJUtils tipWithText:@"删除爱车成功" andView:self.view];
            [weakSelf getCarListFromServer];
        } fail:^{
            
        }];
        [weakSelf hideWindow];
    } andCancleHandler:^{
        
    }];
}

- (void)setDefaultAcitonCallBack:(id)sender
{
    HaveCarsForm* carForm = carList[((UIButton*)sender).tag];
    __weak typeof(self) weakSelf = self;
    [CZJBaseDataInstance setDefaultCar:@{@"id" : carForm.haveCarID} Success:^(id json) {
        [CZJUtils tipWithText:@"设置默认成功" andView:self.view];
        [weakSelf getCarListFromServer];
    } fail:^{
        
    }];
}

- (IBAction)addMyCarAction:(id)sender
{
    CZJCarBrandChooseController *svc = [[CZJCarBrandChooseController alloc] initWithType:CZJCarListTypeGeneral];
    [self.navigationController pushViewController:svc animated:YES];
}
@end
