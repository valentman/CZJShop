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
    NSInteger _selectIndex;
}
@property (nonatomic, strong) UITableView *tableView;
@property(assign)NSIndexPath* selelctIndexPathZero;
@property(assign)NSIndexPath* selelctIndexPath;

@end

@implementation CZJGoodsListFilterSubController
@synthesize typeId = _typeId;

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
    if (IS_IOS9)
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceBar.width = 50;
        self.navigationItem.rightBarButtonItems = @[spaceBar,rightItem];
    }
    
    [rightItem setTag:1001];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH-50, PJ_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.clipsToBounds = true;
    self.automaticallyAdjustsScrollViewInsets = NO;
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
        NSArray* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"%@",[dict description]);
        
        if ([self.subFilterName isEqualToString:@"品牌"])
        {
            self.subFilterArys = [CZJFilterBrandItemForm objectArrayWithKeyValuesArray:dict];
        }
        if ([self.subFilterName isEqualToString:@"价格"])
        {
            self.subFilterArys = [CZJFilterPriceItemForm objectArrayWithKeyValuesArray:dict];
        }
        [self.tableView reloadData];
        
        
        //默认点击第一个
        if (self.subFilterArys.count>0  && self.selectdCondictionArys.count == 0) {
            [self tableView:self.tableView didSelectRowAtIndexPath: self.selelctIndexPathZero];
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
        selectedView.frame = CGRectMake(PJ_SCREEN_WIDTH- 85, 10, 20 ,12);
        [cell addSubview:selectedView];
        selectedView.hidden = YES;
        [selectedView setTag:5001];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    NSString* name = @"";
    id obj = self.subFilterArys[indexPath.row];
    
    if ([self.subFilterName isEqualToString:@"品牌"])
    {
        name = ((CZJFilterBrandItemForm*)obj).name;
    }
    else if ([self.subFilterName isEqualToString:@"价格"])
    {
        name = ((CZJFilterPriceItemForm*)obj).name;
    }
    else
    {
        name = ((CZJFilterCategoryItemForm*)obj).value;
    }
    cell.textLabel.text = name;
    
    //在没有选择任何选项的时候
    if (0 == _selectIndex && indexPath.row != 0)
    {
        [[cell viewWithTag:5001] setHidden:YES];
        cell.isSelected = NO;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    //如果在这选择页面选择了退出到第一个界面，再返回来的时候，需要呈现已选的选项
    if (self.selectdCondictionArys.count > 0 && indexPath.row != 0)
    {
        for (id filterOjc in self.selectdCondictionArys)
        {
            NSString* subName;
            if ([self.subFilterName isEqualToString:@"品牌"])
            {
                subName = ((CZJFilterBrandItemForm*)filterOjc).name;
            }
            else if ([self.subFilterName isEqualToString:@"价格"])
            {
                subName = ((CZJFilterPriceItemForm*)filterOjc).name;
            }
            else
            {
                subName = ((CZJFilterCategoryItemForm*)filterOjc).value;
            }
            
            if ([subName isEqualToString:name])
            {
                if ([self.subFilterName isEqualToString:@"价格"]) {
                    [[cell viewWithTag:5001] setHidden:NO];
                    cell.isSelected = YES;
                    cell.textLabel.textColor = CZJREDCOLOR;
                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                    _selelctIndexPath = indexPath;
                }
                else
                {
                    [[cell viewWithTag:5001] setHidden:NO];
                    cell.isSelected = YES;
                    cell.textLabel.textColor = CZJREDCOLOR;
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
    if ([self.subFilterName isEqualToString:@"价格"])
    {
        if (_selectIndex == _selelctIndexPath.row) {
            [self tableView:tableView didDeselectRowAtIndexPath:self.selelctIndexPath];
        }
        if (_selectIndex == 0)
        {
            [self tableView:tableView didDeselectRowAtIndexPath:self.selelctIndexPathZero];
        }
    }
    else
    {
        if (_selectIndex == 0)
        {
            [self tableView:tableView didDeselectRowAtIndexPath:self.selelctIndexPathZero];
        }
    }
    _selectIndex = indexPath.row;
    CZJTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_selectIndex == 0)
    {
        [[cell viewWithTag:5001] setHidden:NO];
        cell.isSelected = YES;
        cell.textLabel.textColor = CZJREDCOLOR;
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
            cell.textLabel.textColor = CZJREDCOLOR;

            if ([self.subFilterName isEqualToString:@"价格"])
            {
                [self.selectdCondictionArys removeAllObjects];
            }
            [self.selectdCondictionArys addObject:self.subFilterArys[indexPath.row]];
        }
        
        if (![self.subFilterName isEqualToString:@"价格"] && 0 != _selectIndex)
        {
            CZJTableViewCell* cellfirst = [tableView cellForRowAtIndexPath:self.selelctIndexPathZero];
            [[cellfirst viewWithTag:5001] setHidden:YES];
            cellfirst.isSelected = NO;
            cellfirst.textLabel.textColor = [UIColor blackColor];
        }
        
        //俩种情况会选择全部（1.去选掉所有可选选项时，2.选择所有可选项时）
        DLog(@"%ld,%ld",self.selectdCondictionArys.count,self.subFilterArys.count);
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
        DLog(@"selectcount:%ld",self.selectdCondictionArys.count);
    }
    else if (_selectIndex == 0)
    {
        [[cell viewWithTag:5001] setHidden:YES];
        cell.isSelected = NO;
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

@end
