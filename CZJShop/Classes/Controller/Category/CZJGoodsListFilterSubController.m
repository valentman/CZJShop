//
//  CZJGoodsListFilterSubController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsListFilterSubController.h"
#import "CZJBaseDataManager.h"

@interface CZJGoodsListFilterSubController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableDictionary* goodsListFilterSubPostParams;
    NSMutableDictionary* currentSelectedBackDict;
}
@property (nonatomic, strong) UITableView *tableView;
@property(assign,nonatomic) NSInteger selectIndex;
@property(assign)NSIndexPath* selelctIndexPathZero;

@end

@implementation CZJGoodsListFilterSubController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
}


- (void)initDatas
{
    self.title = self.subFilterName;
    goodsListFilterSubPostParams = [NSMutableDictionary dictionary];
    currentSelectedBackDict = [NSMutableDictionary dictionary];
    _selectIndex = -1;
    self.selelctIndexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
}


- (void)initViews
{
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightBtn addTarget:self action:@selector(navBackBarAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setTag:1001];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem setTag:1001];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.clipsToBounds = true;
    [self.view addSubview:self.tableView];
    if ([self.subFilterName isEqualToString:@"品牌"] ||
        [self.subFilterName isEqualToString:@"价格"]) {
        [self getBrandAndPriceFromServer];
    }
    else
    {
        [self.tableView reloadData];
        //默认点击第一个
        if (self.subFilterArys.count>0 && self.selectdCondictionArys.count == 0) {
            [self tableView:self.tableView didSelectRowAtIndexPath: self.selelctIndexPathZero];
        }
    }
}


- (void)getBrandAndPriceFromServer
{
    [goodsListFilterSubPostParams setObject:self.typeId forKey:@"typeId"];
    CZJSuccessBlock successBlock = ^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        
        self.subFilterArys = [dict valueForKey:@"msg"];
        [self.tableView reloadData];
        //默认点击第一个
        
        if (self.subFilterArys.count>0  && self.selectdCondictionArys.count == 0) {
            [self tableView:self.tableView didSelectRowAtIndexPath: self.selelctIndexPathZero];
        }
        else if ([self.subFilterName isEqualToString:@"价格"])
        {
            
        }
    };
    
    [CZJBaseDataInstance loadGoodsPriceOrBrandList:goodsListFilterSubPostParams
                                              type:self.subFilterName
                                           success:successBlock
                                              fail:^{}];
}

- (void)navBackBarAction:(UIBarButtonItem *)bar{
    if (self.navigationController.viewControllers.count > 1) {
        
        [currentSelectedBackDict setObject:self.selectdCondictionArys.count > 0 ? self.selectdCondictionArys : [NSMutableArray array] forKey:self.subFilterName];
        DLog(@"%@",[currentSelectedBackDict description]);
        
        if ([self.delegate respondsToSelector:@selector(sendChoosedDataBack:)])
        {
            [self.delegate sendChoosedDataBack:currentSelectedBackDict];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self cancelAction:bar];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _subFilterArys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    CZJTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    if (!cell)
    {
        cell = [[CZJTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell2"];
        UIImageView* selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shaixuan_icon_gou_sel"]];
        selectedView.frame = CGRectMake(cell.frame.size.width - 10, 10, 20 ,12);
        [cell addSubview:selectedView];
        selectedView.hidden = YES;
        [selectedView setTag:5001];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    NSString* name = [_subFilterArys[indexPath.row] valueForKey:@"value"];
    if ([self.subFilterName isEqualToString:@"品牌"] ||
        [self.subFilterName isEqualToString:@"价格"]) {
        name = [_subFilterArys[indexPath.row] valueForKey:@"name"];
    }
    cell.textLabel.text = name;
    
    //在没有选择任何选项的时候
    if (0 == self.selectIndex && indexPath.row != 0)
    {
        [[cell viewWithTag:5001] setHidden:YES];
        cell.isSelected = NO;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    //如果在这选择页面选择了退出到第一个界面，再返回来的时候，需要呈现已选的选项
    DLog(@"cout:%ld",self.selectdCondictionArys.count);
    if (self.selectdCondictionArys.count > 0 && indexPath.row != 0)
    {
        for (NSDictionary* dict in self.selectdCondictionArys)
        {
            DLog(@"%@",[dict description]);
            NSString* subName;
            if ([self.subFilterName isEqualToString:@"品牌"] ||
                [self.subFilterName isEqualToString:@"价格"])
            {
                subName = [dict valueForKey:@"name"];
            }
            else
            {
                subName = [dict valueForKey:@"value"];
            }

            if ([subName isEqualToString:name])
            {
                if ([self.subFilterName isEqualToString:@"价格"]) {
//                    [self tableView:self.tableView didSelectRowAtIndexPath: self.selelctIndexPathZero];
//                    [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
//                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    [[cell viewWithTag:5001] setHidden:NO];
                    cell.isSelected = YES;
                    cell.textLabel.textColor = [UIColor redColor];
                }
                else
                {
                    [[cell viewWithTag:5001] setHidden:NO];
                    cell.isSelected = YES;
                    cell.textLabel.textColor = [UIColor redColor];
                }
            }
        }
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectIndex == 0)
    {
        [self tableView:tableView didDeselectRowAtIndexPath:self.selelctIndexPathZero];
    }
    self.selectIndex = indexPath.row;
    CZJTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.selectIndex == 0)
    {
        [[cell viewWithTag:5001] setHidden:NO];
        cell.isSelected = YES;
        cell.textLabel.textColor = [UIColor redColor];
        [self.selectdCondictionArys removeAllObjects];
        [self.tableView reloadData];
    }
    else
    {
        //这是可以多选的状态
        if (cell.isSelected)
        {
            [[cell viewWithTag:5001] setHidden:YES];
            cell.isSelected = NO;
            cell.textLabel.textColor = [UIColor blackColor];
            [self.selectdCondictionArys removeObject:self.subFilterArys[indexPath.row]];
        }
        else
        {
            if (self.selectdCondictionArys.count >= 5)
            {
                DLog(@"最多选五个");
                return;
            }
            [[cell viewWithTag:5001] setHidden:NO];
            cell.isSelected = YES;
            cell.textLabel.textColor = [UIColor redColor];

            [self.selectdCondictionArys addObject:self.subFilterArys[indexPath.row]];
        }
        
        if (![self.subFilterName isEqualToString:@"价格"] && 0 != self.selectIndex)
        {
            CZJTableViewCell* cellfirst = [tableView cellForRowAtIndexPath:self.selelctIndexPathZero];
            [[cellfirst viewWithTag:5001] setHidden:YES];
            cellfirst.isSelected = NO;
            cellfirst.textLabel.textColor = [UIColor blackColor];
        }
        if (self.selectdCondictionArys.count == 0 ||
            self.selectdCondictionArys.count >= self.subFilterArys.count - 1)
        {
            [self tableView:tableView didSelectRowAtIndexPath:self.selelctIndexPathZero];
        }
    }

}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJTableViewCell * cell=(CZJTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([self.subFilterName isEqualToString:@"价格"])
    {
        cell.textLabel.textColor= [UIColor blackColor];
        [[cell viewWithTag:5001] setHidden:YES];
        cell.isSelected = NO;
        [self.selectdCondictionArys removeObject:self.subFilterArys[indexPath.row]];
        DLog(@"%ld",self.selectdCondictionArys.count);
    }
    else if (self.selectIndex == 0)
    {
        [[cell viewWithTag:5001] setHidden:YES];
        cell.isSelected = NO;
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

@end
