//
//  CZJPromotionController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/22/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJPromotionController.h"
#import "CZJBaseDataManager.h"
#import "CZJGoodsListCell.h"
#import "CZJPromotionDetailHeadCell.h"
#import "CZJDetailViewController.h"

@interface CZJPromotionController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    CZJPromotionDetailForm* promotionDetailForm;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJPromotionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyViews];
    [self getPromotionDataFromServer];
}

- (void)initMyViews
{
    //导航栏
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"促销活动";
    
    //TableView
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJGoodsListCell",
                         @"CZJPromotionDetailHeadCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getPromotionDataFromServer
{
    __weak typeof(self) weak = self;
    NSDictionary* param = @{@"type":self.type, @"storeId":self.storeId};
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJBaseDataInstance generalPost:param success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        promotionDetailForm = [CZJPromotionDetailForm objectWithKeyValues:dict];
        if (promotionDetailForm.items.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有商品，快去添加吧/(ToT)/~~"];
        }
        else
        {
            [self.myTableView reloadData];
        }
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.myTableView animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getPromotionDataFromServer];
        }];
    } andServerAPI:kCZJServerAPIGetPromotionsList];
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
    if (1 == section)
    {
        return promotionDetailForm.items.count;
    }
    return promotionDetailForm.gifts.count > 0 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJPromotionDetailHeadCell* headCell = [tableView dequeueReusableCellWithIdentifier:@"CZJPromotionDetailHeadCell" forIndexPath:indexPath];
            float height = [CZJUtils calculateStringSizeWithString:promotionDetailForm.rule Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
            headCell.ruleLabelHeight.constant = height > 16 ? height : 16;
            headCell.promotionRuleLabel.text = promotionDetailForm.rule;
            headCell.separatorInset = HiddenCellSeparator;
            headCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return headCell;
        }
        if (1 == indexPath.row)
        {
            UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"giftCell"];
            for (int i = 0; i < promotionDetailForm.gifts.count; i++)
            {
                CZJGoodsDetail* giftForm = promotionDetailForm.gifts[i];
                UIImageView* giftImage = [[UIImageView alloc]init];
                giftImage.backgroundColor = CZJNAVIBARBGCOLOR;
                CGRect giftRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(60, 60) index:i divide:Divide];
                giftImage.frame = giftRect;
                [giftImage sd_setImageWithURL:[NSURL URLWithString:giftForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
                [cell addSubview:giftImage];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    if (1 == indexPath.section)
    {
        CZJGoodsDetail* goodForm = promotionDetailForm.items[indexPath.row];
        CZJGoodsListCell* goodCell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsListCell" forIndexPath:indexPath];
        goodCell.dealName.hidden = YES;
        goodCell.goodRateName.hidden = YES;
        
        goodCell.goodsName.text = goodForm.itemName;
        [goodCell.goodImageView sd_setImageWithURL:[NSURL URLWithString:goodForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        goodCell.goodPrice.text = [NSString stringWithFormat:@"￥%@",goodForm.currentPrice];
        goodCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return goodCell;
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
            float height = [CZJUtils calculateStringSizeWithString:promotionDetailForm.rule Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
            float comp = (height > 16) ? (height - 16) : 0;
            return 70 + comp;
        }
        if (1 == indexPath.row)
        {
            return 80;
        }
    }
    if (1 == indexPath.section)
    {
        return 126;
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
    if (1 == indexPath.section)
    {
        CZJGoodsDetail* goodForm = promotionDetailForm.items[indexPath.row];
        CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
        detailVC.storeItemPid = goodForm.storeItemPid;
        detailVC.promotionPrice = goodForm.currentPrice;
        detailVC.promotionType = CZJGoodsPromotionTypeGeneral;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

@end
