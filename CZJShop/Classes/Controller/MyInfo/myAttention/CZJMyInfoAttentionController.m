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
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"
@interface CZJMyInfoAttentionController ()
<
CZJNaviagtionBarViewDelegate,
LXDSegmentControlDelegate,
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
    
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block CZJHomeGetDataFromServerType _getdataTypeService;
    __block CZJHomeGetDataFromServerType _getdataTypeGoods;
    __block CZJHomeGetDataFromServerType _getdataTypeStore;
    __block NSInteger page;
    __block NSInteger pageService;
    __block NSInteger pageGoods;
    __block NSInteger pageStore;
    
    
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (assign) BOOL isEdit;


- (IBAction)deleteAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;

@end

@implementation CZJMyInfoAttentionController
- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _isEdit = NO;
    _isServiceTouched = NO;
    _isGoodsTouched = NO;
    _isStoreTouched = NO;
    self.buttomView.hidden = !_isEdit;
    
    pageService = 0;
    pageGoods = 0;
    pageStore = 0;
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.delegate = self;
    
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
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        
        switch ([_currentType integerValue])
        {
            case 0:
                pageGoods++;
                page = pageGoods;
                _getdataTypeGoods = CZJHomeGetDataFromServerTypeTwo;
                _getdataType = _getdataTypeGoods;
                break;
                
            case 1:
                pageService++;
                page = pageService;
                _getdataTypeService = CZJHomeGetDataFromServerTypeTwo;
                _getdataType = _getdataTypeService;
                break;
                
            case 2:
                pageStore++;
                page = pageStore;
                _getdataTypeStore = CZJHomeGetDataFromServerTypeTwo;
                _getdataType = _getdataTypeStore;
                break;
                
            default:
                break;
        }
        [weak getDataAttentionDataFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    //segment初始化
    CGRect frame = CGRectMake(100, 5, PJ_SCREEN_WIDTH - 200, 35);
    NSArray * items = @[@"服务", @"商品", @"门店"];
    LXDSegmentControlConfiguration * scale = [LXDSegmentControlConfiguration configurationWithControlType: LXDSegmentControlTypeScaleTitle items: items];
    LXDSegmentControl * scaleControl = [LXDSegmentControl segmentControlWithFrame: frame configuration: scale delegate: self];
    [self.naviBarView addSubview: scaleControl];
}

- (void)getDataAttentionDataFromServer
{
    NSDictionary* params = @{@"type" : _currentType};
    __weak typeof(self) weak = self;
    [tmpArray removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJBaseDataInstance loadMyAttentionList:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        //========获取数据返回，判断数据大于0不==========
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        NSString* prompStr;
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            if (tmpAry.count < 20)
            {
                [refreshFooter noticeNoMoreData];
                return ;
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
            }
            switch ([_currentType integerValue])
            {
                case 0:
                    [goodsAttentionAry addObjectsFromArray:[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] ];
                    _isGoodsTouched = YES;
                    tmpArray = [goodsAttentionAry mutableCopy];
                    break;
                    
                case 1:
                    serviceAttentionAry = [[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    _isServiceTouched = YES;
                    tmpArray = [serviceAttentionAry mutableCopy];
                    break;
                    
                case 2:
                    storeAttentionAry = [[CZJStoreAttentionForm objectArrayWithKeyValuesArray:tmpAry]mutableCopy];
                    _isStoreTouched = YES;
                    tmpArray = [storeAttentionAry mutableCopy];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            switch ([_currentType integerValue])
            {
                case 0:
                    goodsAttentionAry = [[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    _isGoodsTouched = YES;
                    tmpArray = [goodsAttentionAry mutableCopy];
                    prompStr = @"木有关注的商品/(ToT)/~~";
                    break;
                    
                case 1:
                    serviceAttentionAry = [[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    _isServiceTouched = YES;
                    tmpArray = [serviceAttentionAry mutableCopy];
                    prompStr = @"木有关注的服务/(ToT)/~~";
                    break;
                    
                case 2:
                    storeAttentionAry = [[CZJStoreAttentionForm objectArrayWithKeyValuesArray:tmpAry]mutableCopy];
                    _isStoreTouched = YES;
                    tmpArray = [storeAttentionAry mutableCopy];
                    prompStr = @"木有关注的门店/(ToT)/~~";

                    break;
                    
                default:
                    break;
            }
            
        }
        
        if (tmpArray.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:prompStr];
        }
        else
        {
            self.myTableView.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            VIEWWITHTAG(self.naviBarView, 1999).hidden = tmpArray.count == 0 ? YES : NO;
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }
        
    } fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getDataAttentionDataFromServer];
        }];
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
    self.buttomView.hidden = !self.isEdit;
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


#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tmpArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_currentType isEqualToString:@"2"])
    {
        CZJStoreAttentionForm* form = tmpArray[indexPath.section];
        CZJStoreAttentionHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreAttentionHeadCell" forIndexPath:indexPath];
        [cell.storeImg sd_setImageWithURL:[NSURL URLWithString:form.homeImg] placeholderImage:DefaultPlaceHolderImage];
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
        CZJGoodsAttentionForm* form = tmpArray[indexPath.row];
        CZJGoodsAttentionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsAttentionCell" forIndexPath:indexPath];
        [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderImage];
        
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

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_currentType isEqualToString:@"2"])
    {
        return 106;
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
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [tmpArray removeAllObjects];
    self.myTableView.hidden = YES;
    self.isEdit = NO;
    ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).selected = NO;
    self.buttomView.hidden = !_isEdit;
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
        _getdataTypeGoods = CZJHomeGetDataFromServerTypeOne;
        [self getDataAttentionDataFromServer];
    }
    else if (!_isGoodsTouched && 1 == index)
    {
        _getdataTypeService = CZJHomeGetDataFromServerTypeOne;
        [self getDataAttentionDataFromServer];
    }
    else if (!_isStoreTouched && 2 == index)
    {
        _getdataTypeStore = CZJHomeGetDataFromServerTypeOne;
        [self getDataAttentionDataFromServer];
    }
    else
    {
        if (0 == index)
        {
            tmpArray = [serviceAttentionAry mutableCopy];
            if (tmpArray.count == 0)
            {
                ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).hidden = YES;
                [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有关注的服务/(ToT)/~~"];
                return;
            }
        }
        else if (1 == index)
        {
            tmpArray = [goodsAttentionAry mutableCopy];
            if (tmpArray.count == 0)
            {
                ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).hidden = YES;
                [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有关注的商品/(ToT)/~~"];
                return;
            }
        }
        else
        {
            tmpArray = [storeAttentionAry mutableCopy];
            if (tmpArray.count == 0)
            {
                 ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).hidden = YES;
                [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有关注的门店/(ToT)/~~"];
                return;
            }
        }
        self.myTableView.hidden = NO;
        [self.myTableView reloadData];
    }
    VIEWWITHTAG(self.naviBarView, 1999).hidden = tmpArray.count == 0 ? YES : NO;
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
