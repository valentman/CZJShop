//
//  CZJMyWalletCardDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCardDetailController.h"
#import "CZJMyWalletCardCell.h"
#import "CZJMyWalletCardItemCell.h"
#import "CZJMyWalletCardItemLeftCell.h"
#import "CZJRedPacketUseCaseCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMyWalletCardDetailController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* _cardDetailAry;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyWalletCardDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getCardDetailInfoFromServer];
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnBack.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    self.view.backgroundColor = WHITECOLOR;
    
    NSArray* nibArys = @[@"CZJMyWalletCardCell",
                         @"CZJRedPacketUseCaseCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getCardDetailInfoFromServer
{
    
    [CZJBaseDataInstance generalPost:@{@"SetmenuId" : _cardInfoForm.setmenuId} success:^(id json) {
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"%@",[[[CZJUtils DataFromJson:json] valueForKey:@"msg"] description]);
        _cardDetailAry = [CZJCardDetailInfoForm objectArrayWithKeyValuesArray:dict];
        [self.myTableView reloadData];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIShowCardDetail];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else
    {
        return _cardDetailAry.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        CZJMyWalletCardCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyWalletCardCell" forIndexPath:indexPath];
        cell.cardTypeWidth.constant = [CZJUtils calculateTitleSizeWithString:_cardInfoForm.setmenuName AndFontSize:17].height + 5;
        cell.storeNameLabel.text = _cardInfoForm.storeName;
        cell.cardTypeLabel.text = _cardInfoForm.setmenuName;
        [cell setCardCellWithCardDetailInfo:_cardInfoForm];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        CZJCardDetailInfoForm* cardDetailForm = _cardDetailAry[indexPath.row];
        CZJRedPacketUseCaseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJRedPacketUseCaseCell" forIndexPath:indexPath];
        float leftViewWidth = (PJ_SCREEN_WIDTH - 50)*0.5;
        if (indexPath.row % 2 == 0)
        {
            cell.leftView.hidden = YES;
            cell.leftLabel.text = cardDetailForm.createTime;
            cell.rightBalanceName.hidden = YES;
            cell.rightBalanceLabel.hidden = YES;
            cell.rightNumberLabel.hidden = YES;
            
            for (int i = 0; i < cardDetailForm.items.count; i++)
            {
                CZJCardDetailInfoFormItem* cardDetailItemForm = cardDetailForm.items[i];
                CZJMyWalletCardItemCell* itemCell = [CZJUtils getXibViewByName:@"CZJMyWalletCardItemCell"];
                itemCell.itemNameLabel.text = [NSString stringWithFormat:@"(扣%@次)%@",cardDetailItemForm.useCount, cardDetailItemForm.itemName];
                itemCell.itemNamelabelWidth.constant = [CZJUtils calculateStringSizeWithString:itemCell.itemNameLabel.text Font:itemCell.itemNameLabel.font Width:leftViewWidth].width + 10;
                itemCell.dotLabel.backgroundColor = CZJGRAYCOLOR;
                itemCell.backgroundColor = CLEARCOLOR;
                itemCell.contentView.backgroundColor = CLEARCOLOR;
                itemCell.frame = CGRectMake(-10, 5 + i*20, leftViewWidth, 20);
                [cell.rightView addSubview:itemCell];
            }
        }
        else
        {
            cell.rightView.hidden = YES;
            cell.rightLabel.text = cardDetailForm.createTime;
            cell.leftBalanceName.hidden = YES;
            cell.leftBalanceLabel.hidden = YES;
            cell.leftNumberLabel.hidden = YES;
            
            for (int i = 0; i < cardDetailForm.items.count; i++)
            {
                CZJCardDetailInfoFormItem* cardDetailItemForm = cardDetailForm.items[i];
                CZJMyWalletCardItemLeftCell* itemCell = [CZJUtils getXibViewByName:@"CZJMyWalletCardItemLeftCell"];
                itemCell.itemNameLabel.text = [NSString stringWithFormat:@"(扣%@次)%@",cardDetailItemForm.useCount, cardDetailItemForm.itemName];
                itemCell.itemNameLabelWidth.constant = [CZJUtils calculateStringSizeWithString:itemCell.itemNameLabel.text Font:itemCell.itemNameLabel.font Width:leftViewWidth].width + 10;
                itemCell.dotLabel.backgroundColor = CZJGRAYCOLOR;
                itemCell.contentView.backgroundColor = CLEARCOLOR;
                itemCell.frame = CGRectMake(0, 5 + i*20, leftViewWidth, 20);
                [itemCell setPosition:CGPointMake(leftViewWidth-5, 5 + i*20) atAnchorPoint:CGPointTopRight];
                [cell.leftView addSubview:itemCell];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return  190 + 35 * _cardInfoForm.items.count;
    }
    else
    {
        CZJCardDetailInfoForm* cardDetailForm = _cardDetailAry[indexPath.row];
        
        return 40 + cardDetailForm.items.count * 20;
    }
    return 100;
}

@end
