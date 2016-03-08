//
//  CZJCommitReturnController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/8/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJCommitReturnController.h"
#import "CZJSerFilterTypeChooseCell.h"
#import "CZJOrderReturnedListCell.h"
#import "CZJCommitReturnTypeCell.h"

@interface CZJCommitReturnController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    __block NSInteger returnType;           //退换货类型
    NSString* chooseTypeStr;
    CZJCommitReturnTypeCell* promptCell;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJCommitReturnController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"退换货";
    [self initViews];
}

- (void)initViews
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CZJTableViewBGColor;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderReturnedListCell",
                         @"CZJCommitReturnTypeCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    if (1 == section)
    {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderReturnedListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderReturnedListCell" forIndexPath:indexPath];
            cell.goodNameLabel.text = _returnedGoodsForm.itemName;
            cell.goodModelLabel.text = _returnedGoodsForm.itemSku;
            cell.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",_returnedGoodsForm.currentPrice];
            [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:_returnedGoodsForm.itemImg] placeholderImage:IMAGENAMED(@"")];
            cell.returnBtn.hidden = YES;
            cell.returnStateLabel.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell4"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setButtonDatas:@[@"退货",@"换货"] WithType:kCZJSerfilterTypeChooseCellTypeReturnGoods];
            CZJButtonBlock buttonHandler = ^(UIButton* button){
                returnType = button.tag;
                if ([button.titleLabel.text isEqualToString:@"退货"])
                {
                    returnType = 0;
                    promptCell.promptLabel.text = @"您选择了退货，请与卖家协商达成退货。";
                }
                if ([button.titleLabel.text isEqualToString:@"换货"])
                {
                    returnType = 1;
                    promptCell.promptLabel.text = @"您选择了换货，请与卖家协商达成退货。";
                }
            };
            [cell setButtonBlock:buttonHandler];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        if (2 == indexPath.row)
        {
            promptCell = [tableView dequeueReusableCellWithIdentifier:@"CZJCommitReturnTypeCell" forIndexPath:indexPath];
            promptCell.backgroundColor = WHITECOLOR;
            return promptCell;
        }
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {

        }
        if (1 == indexPath.row)
        {
            //动态改变

        }
        if (2 == indexPath.row)
        {

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
            return 100;
        }
        if (1 == indexPath.row)
        {
            return 80;
        }
        if (2 == indexPath.row)
        {
            return 56;
        }
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 50;
        }
        if (1 == indexPath.row)
        {
            //动态改变
            return 0;
        }
        if (2 == indexPath.row)
        {
            return 100;
        }
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


@end
