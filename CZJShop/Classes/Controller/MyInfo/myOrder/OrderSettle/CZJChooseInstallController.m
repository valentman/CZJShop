//
//  CZJChooseInstallController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChooseInstallController.h"
#import "CZJBaseDataManager.h"
#import "CZJStoreForm.h"
#import "CZJChooseInstallStoreCell.h"

@interface CZJChooseInstallController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* storeList;
    CZJNearbyStoreForm* selectdForm;
}
@property (weak, nonatomic) IBOutlet UITableView *myStoreListTableView;
@property (weak, nonatomic) IBOutlet UIButton *selfSetupBtn;
@property (weak, nonatomic) IBOutlet UIButton *storeSetupBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promptLabelLayoutWidth;
@property (weak, nonatomic) IBOutlet UILabel *setupPriceLabel;

- (IBAction)setupSelfAction:(id)sender;
- (IBAction)setupStoreAction:(id)sender;
- (IBAction)confirmToUseAction:(id)sender;
@end

@implementation CZJChooseInstallController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"选择安装门店";
    _promptLabelLayoutWidth.constant = PJ_SCREEN_WIDTH - 50;

    
    self.myStoreListTableView.delegate = self;
    self.myStoreListTableView.dataSource = self;
    self.myStoreListTableView.tableFooterView = [[UIView alloc]init];
    UINib* nib = [UINib nibWithNibName:@"CZJChooseInstallStoreCell" bundle:nil];
    [self.myStoreListTableView registerNib:nib forCellReuseIdentifier:@"CZJChooseInstallStoreCell"];
    
    
    
    if (!_orderGoodsForm.setupStoreId)
    {
        [self setupSelfAction:nil];
    }
    else
    {
        [self setupStoreAction:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getStoreListFromServer
{
    NSDictionary* params = @{@"storeItemPid":_orderGoodsForm.storeItemPid};
    [CZJBaseDataInstance loadStoreSetupList:params Success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpAry = [dict valueForKey:@"msg"];
        storeList = [CZJNearbyStoreForm objectArrayWithKeyValuesArray:tmpAry];
        [self.myStoreListTableView reloadData];
    } fail:nil];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return storeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJNearbyStoreForm* form = storeList[indexPath.row];
    CZJChooseInstallStoreCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJChooseInstallStoreCell" forIndexPath:indexPath];
    [cell.storeImg sd_setImageWithURL:[NSURL URLWithString:form.homeImg] placeholderImage:DefaultPlaceHolderSquare];
    cell.storeNameLabel.text = form.name;
    cell.storeAddrLabel.text = form.addr;
    cell.setupNumLabel.text = form.setupCount;
    cell.servicePriceLabel.text = [NSString stringWithFormat:@"￥%@",form.setupPrice];
    cell.otherLabel.text = form.distance;
    cell.starLabel.text = form.evaluationAvg;
    CGSize size = [CZJUtils calculateStringSizeWithString:form.addr Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH -170];
    cell.storeAddrLayoutWidth.constant = size.width;
    cell.storeAddrLayoutHeight.constant = size.height;
    
    if ([_orderGoodsForm.setupStoreId isEqualToString:form.storeId])
    {
        cell.selectBtn.selected = YES;
        self.setupPriceLabel.text = [NSString stringWithFormat:@"￥%@",_orderGoodsForm.setupPrice];
    }
    else
    {
        cell.selectBtn.selected = NO;
        self.setupPriceLabel.text = [NSString stringWithFormat:@"￥%@",@"0"];
    }
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJChooseInstallStoreCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectBtn.selected = YES;
    selectdForm = storeList[indexPath.row];
    self.setupPriceLabel.text = [NSString stringWithFormat:@"￥%@",selectdForm.setupPrice];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJChooseInstallStoreCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectBtn.selected = NO;
}

- (IBAction)setupSelfAction:(id)sender
{
    self.myStoreListTableView.hidden = YES;
    _selfSetupBtn.selected = YES;
    _storeSetupBtn.selected = NO;
    [self.selfSetupBtn setBackgroundColor:CZJREDCOLOR];
    self.selfSetupBtn.layer.borderColor = CZJREDCOLOR.CGColor;
    
    [self.storeSetupBtn setBackgroundColor:[UIColor whiteColor]];
    self.storeSetupBtn.layer.borderColor = CZJGRAYCOLOR.CGColor;
    self.storeSetupBtn.layer.borderWidth = 0.5;
    
    self.setupPriceLabel.text = [NSString stringWithFormat:@"￥%@",@"0"];
}

- (IBAction)setupStoreAction:(id)sender
{
    self.myStoreListTableView.hidden = NO;
    _selfSetupBtn.selected = NO;
    _storeSetupBtn.selected = YES;
    
    [self.storeSetupBtn setBackgroundColor:CZJREDCOLOR];
    self.storeSetupBtn.layer.borderColor = CZJREDCOLOR.CGColor;
    
    [self.selfSetupBtn setBackgroundColor:[UIColor whiteColor]];
    self.selfSetupBtn.layer.borderColor = CZJGRAYCOLOR.CGColor;
    self.selfSetupBtn.layer.borderWidth = 0.5;
    [self getStoreListFromServer];
}

- (IBAction)confirmToUseAction:(id)sender
{
    if (_selfSetupBtn.selected)
    {
        [self.delegate clickSelectInstallStore:nil];
    }
    if (_storeSetupBtn.selected)
    {
        [self.delegate clickSelectInstallStore:selectdForm];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
