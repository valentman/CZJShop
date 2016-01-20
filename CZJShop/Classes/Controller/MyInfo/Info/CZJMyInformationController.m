//
//  CZJMyInformationController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInformationController.h"
#import "CZJMyInfoHeadCell.h"
#import "CZJMyInfoShoppingCartCell.h"
#import "CZJGeneralCell.h"
#import "CZJGeneralSubCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMyInformationController ()
<UITableViewDataSource,
UITableViewDelegate,
CZJGeneralSubCellDelegate,
CZJMyInfoHeadCellDelegate,
CZJMyInfoShoppingCartCellDelegate
>
{
    NSArray* orderSubCellAry;           //订单cell下子项数组
    NSArray* walletSubCellAry;          //我的钱包下子项数组
}
@property (weak, nonatomic) IBOutlet UITableView *myInfoTableView;

@end

@implementation CZJMyInformationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dealWithInitNavigationBar];
    [self initDatas];
    [self initViews];
    [self getMyInfoDataFromServer];
}

- (void)dealWithInitNavigationBar
{
    /**
     *  注意：一旦你设置了navigationBar的- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics接口，那么上面的setBarTintColor接口就不能改变statusBar的背景色
     */
    //导航栏背景透明化
    id navigationBarAppearance = self.navigationController.navigationBar;
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"nav_bargound"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.navigationBar.shadowImage =[UIImage imageNamed:@"nav_bargound"];
}

- (void)initDatas
{
    orderSubCellAry  = [NSArray array];
    walletSubCellAry = [NSArray array];
    NSDictionary* dict1 = @{@"title":@"待付款", @"buttonImage":@"my_icon_pay", @"budge":@"2"};
    NSDictionary* dict2 = @{@"title":@"待施工", @"buttonImage":@"my_icon_shigong", @"budge":@"50"};
    NSDictionary* dict3 = @{@"title":@"待施工", @"buttonImage":@"my_icon_shouhuo", @"budge":@"3"};
    NSDictionary* dict4 = @{@"title":@"待评价", @"buttonImage":@"my_icon_recommend", @"budge":@"4"};
    NSDictionary* dict5 = @{@"title":@"退换货", @"buttonImage":@"my_icon_tuihuo", @"budge":@""};
    orderSubCellAry = @[dict1,dict2,dict3,dict4,dict5];
    NSDictionary* dict6 = @{@"title":@"账户余额", @"buttonTitle":@"2000.00"};
    NSDictionary* dict7 = @{@"title":@"红包", @"buttonTitle":@"20.0"};
    NSDictionary* dict8 = @{@"title":@"积分", @"buttonTitle":@"500"};
    NSDictionary* dict9 = @{@"title":@"优惠券", @"buttonTitle":@"5"};
    NSDictionary* dict0 = @{@"title":@"套餐卡", @"buttonTitle":@"6"};
    walletSubCellAry = @[dict6,dict7,dict8,dict9,dict0];
}

- (void)initViews
{
    self.myInfoTableView.delegate = self;
    self.myInfoTableView.dataSource = self;
    NSArray* nibArys = @[@"CZJMyInfoHeadCell",
                         @"CZJMyInfoShoppingCartCell",
                         @"CZJGeneralCell",
                         @"CZJGeneralSubCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myInfoTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myInfoTableView.tableFooterView = [[UIView alloc] init];
    self.myInfoTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)getMyInfoDataFromServer
{
    if ([USER_DEFAULT boolForKey:kCZJIsUserHaveLogined])
    {//
        [CZJBaseDataInstance getUserInfo:nil Success:^(id json) {
            
        } fail:^{
            
        }];
    }

    [self.myInfoTableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 4;
    }
    else
    {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJMyInfoHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyInfoHeadCell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
        else if (1 == indexPath.row)
        {
            CZJMyInfoShoppingCartCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyInfoShoppingCartCell" forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
        else if (2 == indexPath.row)
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
            [cell.imageView setImage:nil];
            [cell.imageView setImage:IMAGENAMED(@"my_icon_list")];
            cell.nameLabel.text = @"我的订单";
            cell.detailLabel.hidden = NO;
            return cell;
        }
        else
        {
            CZJGeneralSubCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralSubCell" forIndexPath:indexPath];
            [cell setGeneralSubCell:orderSubCellAry andType:kCZJGeneralSubCellTypeOrder];
            return cell;
        }
    }
    else if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell"];
            cell.imageView.image = IMAGENAMED(@"");
            [cell.imageView setImage:IMAGENAMED(@"my_icon_wallet")];
            cell.nameLabel.text = @"我的钱包";
            
            return cell;
        }
        else
        {
            CZJGeneralSubCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralSubCell" forIndexPath:indexPath];
            [cell setGeneralSubCell:walletSubCellAry andType:kCZJGeneralSubCellTypeWallet];
            return cell;
        }
    }
    else if (2 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
            [cell.imageView setImage:IMAGENAMED(@"my_icon_erweima")];
            cell.nameLabel.text = @"分享优惠码";
            return cell;
        }
        else
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
            [cell.imageView setImage:IMAGENAMED(@"my_icon_input")];
            cell.nameLabel.text = @"输入优惠码";
            return cell;
        }
    }
    else if (3 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
            [cell.imageView setImage:IMAGENAMED(@"my_icon_serve")];
            cell.nameLabel.text = @"服务于反馈";
            return cell;
        }
        else
        {
            CZJGeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGeneralCell" forIndexPath:indexPath];
            [cell.imageView setImage:IMAGENAMED(@"my_icon_set")];
            cell.nameLabel.text = @"设置";
            return cell;
        }
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 170;
        }
        else if (1 == indexPath.row)
        {
            return 56;
        }
        else if (2 == indexPath.row)
        {
            return 46;
        }
        else
        {
            return 60;
        }
    }
    else if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 46;
        }
        else
        {
            return 60;
        }
    }
    else
    {
        return 46;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* segueIdentifer;
    
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            segueIdentifer = @"segueToPersonalInfo";
        }
        if (2 == indexPath.row)
        {
            segueIdentifer = @"segueToMyWallet";
        }
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            segueIdentifer = @"segueToMyWallet";
        }
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0) {
            segueIdentifer = @"segueToShare";
        }
        else
        {
            segueIdentifer = @"segueToInputCode";
        }
    }
    if (indexPath.section == 3)
    {
        if (indexPath.row == 0) {
            segueIdentifer = @"segueToService";
        }
        else
        {
            segueIdentifer = @"segueToSetting";
        }
    }
    if (segueIdentifer)
    {
        [self performSegueWithIdentifier:segueIdentifer sender:self];
    }

}

#pragma mark- CZJGeneralSubCellDelegate
- (void)clickSubCellButton:(UIButton*)button
{
    
}


#pragma mark- CZJMyInfoHeadCellDelegate


#pragma mark- CZJMyInfoShoppingCartCellDelegate
- (void)clickMyInfoShoppingCartCell:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag)
    {
        case 0:
        {
            UIViewController *shoppingcart = [CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"SBIDShoppingCart"];
            [self.navigationController pushViewController:shoppingcart animated:true];
        }
            break;
        case 1:
            [self performSegueWithIdentifier:@"segueToMyAttention" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"segutToRecord" sender:self];
            break;
            
        default:
            break;
    }
}


#pragma mark- CZJMyInfoHeadCellDelegate
-(void)clickMyInfoHeadCell
{
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //如果没有登录则进入登录页面
    if (![USER_DEFAULT boolForKey:kCZJIsUserHaveLogined])
    {
        [CZJUtils showLoginView:self];
    }
}


@end
