//
//  CZJMyInfoAttentionController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoAttentionController.h"
#import "PullTableView.h"
#import "LXDSegmentControl.h"
#import "CZJBaseDataManager.h"
#import "CZJAttentionForm.h"
#import "CZJGoodsAttentionCell.h"
#import "CZJStoreAttentionCell.h"
#import "CZJStoreAttentionHeadCell.h"
#import "UIImageView+WebCache.h"
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"
@interface CZJMyInfoAttentionController ()
<
CZJNaviagtionBarViewDelegate,
LXDSegmentControlDelegate,
PullTableViewDelegate,
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NSString* _currentType;
    NSMutableArray* serviceAttentionAry;
    NSMutableArray* goodsAttentionAry;
    NSMutableArray* storeAttentionAry;
    NSMutableArray* tmpArray;
    NSMutableArray* deleteIdAry;
    
    BOOL _isEdit;
    BOOL _isServiceTouched;
    BOOL _isGoodsTouched;
    BOOL _isStoreTouched;
    
}
@property (weak, nonatomic) IBOutlet PullTableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepratorViewHeight;
@property (assign) BOOL isEdit;


- (IBAction)deleteAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;

@end

@implementation CZJMyInfoAttentionController
@synthesize isEdit = _isEdit;
- (void)viewDidLoad {
    [super viewDidLoad];
    _sepratorViewHeight.constant = 0.5;
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    [self initDatas];
    [self initViews];
}

- (void)initDatas
{
    serviceAttentionAry = [NSMutableArray array];
    goodsAttentionAry = [NSMutableArray array];
    storeAttentionAry = [NSMutableArray array];
    tmpArray = [NSMutableArray array];
    deleteIdAry = [NSMutableArray array];
    
    _isEdit = YES;
    _isServiceTouched = NO;
    _isGoodsTouched = NO;
    _isStoreTouched = NO;
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(PJ_SCREEN_WIDTH - 59 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitle:@"完成" forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = BOLDSYSTEMFONT(16);
    [rightBtn setTag:1999];
    [self.naviBarView addSubview:rightBtn];
    

    NSArray* nibArys = @[@"CZJGoodsAttentionCell",
                         @"CZJStoreAttentionHeadCell",
                         @"CZJStoreAttentionCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    //segment初始化
    CGRect frame = CGRectMake(100, 5, PJ_SCREEN_WIDTH - 200, 35);
    NSArray * items = @[@"服务", @"商品", @"门店"];
    LXDSegmentControlConfiguration * scale = [LXDSegmentControlConfiguration configurationWithControlType: LXDSegmentControlTypeScaleTitle items: items];
    LXDSegmentControl * scaleControl = [LXDSegmentControl segmentControlWithFrame: frame configuration: scale delegate: self];

//    [self edit:nil];
    
    
     self.naviBarView.delegate = self;
    [self.naviBarView addSubview: scaleControl];
}

- (void)getDataAttentionDataFromServer
{
    NSDictionary* params = @{@"type" : _currentType};
    [CZJBaseDataInstance loadMyAttentionList:params success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpAry = [dict valueForKey:@"msg"];
        for (int i = 0; i < tmpAry.count ; i++)
        {
            NSDictionary* tmpDict = tmpAry[i];
            switch ([_currentType integerValue])
            {
                case 0:
                {
                    CZJGoodsAttentionForm* form = [[CZJGoodsAttentionForm alloc]initWithDictionary:tmpDict];
                    [goodsAttentionAry addObject:form];
                    
                }
                    break;
                case 1:
                {
                    CZJGoodsAttentionForm* form = [[CZJGoodsAttentionForm alloc]initWithDictionary:tmpDict];
                    [serviceAttentionAry addObject:form];
                    
                }
                    break;
                case 3:
                {
                    CZJStoreAttentionForm* form = [[CZJStoreAttentionForm alloc]initWithDictionary:tmpDict];
                    [storeAttentionAry addObject:form];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
        switch ([_currentType integerValue])
        {
            case 0:
                tmpArray = goodsAttentionAry;
                _isGoodsTouched = YES;
                break;
            case 1:
                tmpArray = serviceAttentionAry;
                _isServiceTouched = YES;
                break;
            case 3:
                tmpArray = storeAttentionAry;
                _isStoreTouched = YES;
                break;
            default:
                break;
        }
        self.myTableView.pullDelegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        [self.myTableView reloadData];
        VIEWWITHTAG(self.naviBarView, 1999).hidden = tmpArray.count == 0 ? YES : NO;
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)edit:(id)sender
{
    UIButton* itemButton = (UIButton*)sender;
    itemButton.selected = !itemButton.selected;
    self.isEdit = !self.isEdit;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.buttomView.frame = CGRectMake(0, self.isEdit ? PJ_SCREEN_HEIGHT - 50 : PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, 50);
    } completion:^(BOOL finished) {
        
    }];

    [self.myTableView reloadData];
}

- (void)pitchOn
{
    self.selectAllBtn.selected = YES;
    for (id object in tmpArray)
    {
        if ([_currentType isEqualToString:@"2"])
        {
            CZJStoreAttentionForm* form = (CZJStoreAttentionForm*)object;
            if (!form.isSelected)
            {
                self.selectAllBtn.selected = NO;
            }
            else
            {
                [deleteIdAry addObject:form.attentionID];
            }
            
        }
        else
        {
            CZJGoodsAttentionForm* form = (CZJGoodsAttentionForm*)object;
            if (!form.isSelected)
            {
                self.selectAllBtn.selected = NO;
            }
            else
            {
                [deleteIdAry addObject:form.attentionID];
            }
        }
    }
}

#pragma mark-PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_currentType isEqualToString:@"2"])
    {
        return tmpArray.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_currentType isEqualToString:@"2"])
    {//门店关注列表
        return 2;
    }
    return tmpArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_currentType isEqualToString:@"2"])
    {
        CZJStoreAttentionForm* form = tmpArray[indexPath.section];
        if (0 == indexPath.row)
        {
            CZJStoreAttentionHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreAttentionHeadCell" forIndexPath:indexPath];
            [cell.storeImg sd_setImageWithURL:[NSURL URLWithString:form.homeImg] placeholderImage:nil];
            cell.storeNameLabel.text = form.name;
            CGSize attentionSize = [CZJUtils calculateTitleSizeWithString:form.attentionCount AndFontSize:14];
            cell.attentionCountLabel.text = form.attentionCount;
            cell.attentionCountLayoutWidth.constant = attentionSize.width;
            cell.selectBtn.selected = form.isSelected;
            [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
                cell.viewLayoutLeading.constant = self.isEdit ? 30 : 0;
            } completion:nil];
            return cell;
        }
        else
        {
            CZJStoreAttentionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreAttentionCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else
    {
        CZJGoodsAttentionForm* form = tmpArray[indexPath.row];
        CZJGoodsAttentionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsAttentionCell" forIndexPath:indexPath];
        [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:nil];
        
        CGSize nameSize = [CZJUtils calculateStringSizeWithString:form.itemName Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 116];
        cell.goodNameLabel.text = form.itemName;
        cell.goodNameLayoutHeight.constant = nameSize.height;
        cell.priceLabel.text = form.currentPrice;
        cell.selectBtn.selected = form.isSelected;
        [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            cell.viewLayoutLeading.constant = self.isEdit ? 30 : 0;
        } completion:nil];

        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_currentType isEqualToString:@"2"])
    {//门店关注列表
        if (0 == indexPath.row)
        {
            return 76;
        }
        else
        {
            return 167;
        }
    }
    return 126;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_currentType isEqualToString:@"2"])
    {
        CZJStoreAttentionForm* form = tmpArray[indexPath.section];
        if (self.isEdit)
        {
            form.isSelected = !form.isSelected;
            [self.myTableView reloadData];
        }
        else
        {
            if (0 == indexPath.row)
            {
                [CZJUtils showStoreDetailView:self.navigationController andStoreId:form.storeId];
            }
        }
    }
    else
    {
        CZJGoodsAttentionForm* form = tmpArray[indexPath.row];
        if (self.isEdit)
        {
            form.isSelected = !form.isSelected;
            [self.myTableView reloadData];
        }
        else
        {
            [CZJUtils showGoodsServiceDetailView:self.navigationController andItemPid:form.storeItemPid detailType:[_currentType isEqualToString:@"0"] ? CZJDetailTypeGoods:CZJDetailTypeService];
        }
    }
    [self pitchOn];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_currentType isEqualToString:@"2"])
    {
        if (0 == section)
        {
            return 0;
        }
        return 10;
    }
    return 0;
}


#pragma mark - LXDSegmentControlDelegate
- (void)segmentControl: (LXDSegmentControl *)segmentControl didSelectAtIndex: (NSUInteger)index
{
    DLog(@"%ld",index);
    self.isEdit = NO;
    ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).selected = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.buttomView.frame = CGRectMake(0, self.isEdit ? PJ_SCREEN_HEIGHT - 50 : PJ_SCREEN_HEIGHT, PJ_SCREEN_WIDTH, 50);
    } completion:^(BOOL finished) {
        
    }];
    if (1 == index)
    {
        _currentType = [NSString stringWithFormat:@"%ld",index - 1];
        
    }
    else if (0 == index)
    {
        _currentType = [NSString stringWithFormat:@"%ld",index + 1];

    }
    else
    {
        _currentType =[NSString stringWithFormat:@"%ld",index];
    }
    
    if (!_isServiceTouched && 0 == index)
    {
        [self getDataAttentionDataFromServer];
    }
    else if (!_isGoodsTouched && 1 == index)
    {
        [self getDataAttentionDataFromServer];
    }
    else if (!_isStoreTouched && 2 == index)
    {
        [self getDataAttentionDataFromServer];
    }
    else
    {
        if (0 == index)
        {
            tmpArray = serviceAttentionAry;
        }
        else if (1 == index)
        {
            tmpArray = goodsAttentionAry;
        }
        else
        {
            tmpArray = storeAttentionAry;
        }
        [self.myTableView reloadData];
    }
    VIEWWITHTAG(self.naviBarView, 1999).hidden = tmpArray.count == 0 ? YES : NO;
}

#pragma mark - CZJNaviagtionBarViewDelegate
- (void)clickEventCallBack:(nullable id)sender
{
    UIButton* barButton = (UIButton*)sender;
    switch (barButton.tag) {
        case CZJButtonTypeNaviBarMore:
            break;
            
        case CZJButtonTypeNaviBarBack:
            [self.navigationController popViewControllerAnimated:true];
            break;
            
        case CZJButtonTypeHomeShopping:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - ButtonAction
- (IBAction)deleteAction:(id)sender
{
    NSString* ids = [deleteIdAry componentsJoinedByString:@","];
    NSDictionary* params = @{@"type": _currentType, @"ids":ids};
    [CZJBaseDataInstance cancleAttentionList:params Success:^(id json) {
        
        NSMutableArray* tempAry = [NSMutableArray arrayWithArray:tmpArray];
        for (id object in tempAry)
        {
            if ([_currentType isEqualToString:@"3"])
            {
                CZJStoreAttentionForm* form = (CZJStoreAttentionForm*)object;
                if (form.isSelected)
                {
                    [tmpArray removeObject:object];
                }
            }
            else
            {
                CZJGoodsAttentionForm* form = (CZJGoodsAttentionForm*)object;
                if (form.isSelected)
                {
                    [tmpArray removeObject:object];
                }
            }
        }
        [self.myTableView reloadData];
        [deleteIdAry removeAllObjects];
    } fail:^{
        
    }];
}

- (IBAction)selectAllAction:(id)sender
{
    self.selectAllBtn.selected =  !self.selectAllBtn.selected;
    for (id object in tmpArray)
    {
        if ([_currentType isEqualToString:@"3"])
        {
            CZJStoreAttentionForm* form = (CZJStoreAttentionForm*)object;
            form.isSelected = self.selectAllBtn.selected;
        }
        else
        {
            CZJGoodsAttentionForm* form = (CZJGoodsAttentionForm*)object;
            form.isSelected = self.selectAllBtn.selected;
        }
    }
    [self.myTableView reloadData];
}
@end
