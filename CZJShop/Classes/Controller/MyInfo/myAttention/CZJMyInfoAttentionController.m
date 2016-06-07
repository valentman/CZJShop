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
    __block NSMutableArray* deleteIdAry;
    
    BOOL _isEdit;
    BOOL _isServiceTouched;
    BOOL _isGoodsTouched;
    BOOL _isStoreTouched;
    BOOL _isServiceLoadOver;
    BOOL _isGoodsLoadOver;
    BOOL _isStoreLoadOver;
    
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
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomViewButtom;

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
//    self.buttomView.hidden = !_isEdit;
    
    pageService = 1;
    pageGoods = 1;
    pageStore = 1;
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
    NSDictionary* params = @{@"type" : _currentType, @"page" : [NSString stringWithFormat:@"%ld",page]};
    __weak typeof(self) weak = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJUtils removeReloadAlertViewFromTarget:self.view];
    [CZJBaseDataInstance loadMyAttentionList:params success:^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        
        DLog(@"%@",[[CZJUtils DataFromJson:json] description]);
        //========获取数据返回，判断数据大于0不==========
        [tmpArray removeAllObjects];
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        NSString* prompStr;
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            switch ([_currentType integerValue])
            {
                case 0:
                    [goodsAttentionAry addObjectsFromArray:[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] ];
                    _isGoodsTouched = YES;
                    [tmpArray removeAllObjects];
                    tmpArray = [goodsAttentionAry mutableCopy];
                    break;
                    
                case 1:
                    [serviceAttentionAry addObjectsFromArray:[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry]];
                    _isServiceTouched = YES;
                    [tmpArray removeAllObjects];
                    tmpArray = [serviceAttentionAry mutableCopy];
                    break;
                    
                case 2:
                    [storeAttentionAry addObjectsFromArray:[CZJStoreAttentionForm objectArrayWithKeyValuesArray:tmpAry]];
                    _isStoreTouched = YES;
                    [tmpArray removeAllObjects];
                    tmpArray = [storeAttentionAry mutableCopy];
                    break;
                    
                default:
                    break;
            }
            
            if (tmpAry.count < 20)
            {
                switch ([_currentType integerValue])
                {
                    case 0:
                        _isGoodsLoadOver = YES;
                        break;
                    case 1:
                        _isServiceLoadOver = YES;
                        break;
                    case 2:
                        _isStoreLoadOver = YES;
                        break;
                        
                    default:
                        break;
                }
                [refreshFooter noticeNoMoreData];
                return;
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
                return;
            }
        }
        else
        {
            switch ([_currentType integerValue])
            {
                case 0:
                    goodsAttentionAry = [[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    _isGoodsTouched = YES;
                    [tmpArray removeAllObjects];
                    tmpArray = [goodsAttentionAry mutableCopy];
                    prompStr = @"木有关注的商品/(ToT)/~~";
                    break;
                    
                case 1:
                    serviceAttentionAry = [[CZJGoodsAttentionForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    _isServiceTouched = YES;
                    [tmpArray removeAllObjects];
                    tmpArray = [serviceAttentionAry mutableCopy];
                    prompStr = @"木有关注的服务/(ToT)/~~";
                    break;
                    
                case 2:
                    storeAttentionAry = [[CZJStoreAttentionForm objectArrayWithKeyValuesArray:tmpAry]mutableCopy];
                    _isStoreTouched = YES;
                    [tmpArray removeAllObjects];
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
            [self setButtomViewShowAnimation:NO];
        }
        else
        {
            self.myTableView.hidden = NO;
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            DLog(@"self.myTableView reloadData");
            if (tmpArray.count > 0)
            {
                [self.myTableView reloadData];
                if (weak.isEdit)
                {
                    [weak pitchOn];
                    [weak setButtomViewShowAnimation:YES];
                }
            }
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
    [self setButtomViewShowAnimation:self.isEdit];
    
    [self.myTableView reloadData];
    if (self.isEdit)
    {
        [self pitchOn];
    }
}

- (void)pitchOn
{
    self.selectAllBtn.selected = YES;
    [deleteIdAry removeAllObjects];
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
    self.selectAllBtn.selected = (deleteIdAry.count == tmpArray.count);
    NSString* deletStr = @"取消关注";
    if (deleteIdAry.count > 0)
    {
        _deleteBtn.backgroundColor = CZJREDCOLOR;
        [_deleteBtn setEnabled:YES];
        deletStr = [NSString stringWithFormat:@"取消关注(%ld)",deleteIdAry.count];
    }
    else
    {
        _deleteBtn.backgroundColor = GRAYCOLOR;
        [_deleteBtn setEnabled:NO];
    }
    [self.deleteBtn setTitle:deletStr forState:UIControlStateNormal];
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
        CZJStoreAttentionForm* form = tmpArray[indexPath.row];
        CZJStoreAttentionHeadCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJStoreAttentionHeadCell" forIndexPath:indexPath];
        [cell.storeImg sd_setImageWithURL:[NSURL URLWithString:form.homeImg] placeholderImage:DefaultPlaceHolderSquare];
        cell.storeNameLabel.text = form.name;
        CGSize attentionSize = [CZJUtils calculateTitleSizeWithString:form.attentionCount AndFontSize:14];
        cell.attentionCountLabel.text = form.attentionCount;
        cell.attentionCountLayoutWidth.constant = attentionSize.width + 5;
        cell.selectBtn.selected = form.isSelected;
        
        [cell layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            cell.viewLayoutLeading.constant = _isEdit? 30 : 0;
            [cell layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        
        [cell setSeparatorViewHidden:NO];
        return cell;
    }
    else
    {
        CZJGoodsAttentionForm* form = tmpArray[indexPath.row];
        CZJGoodsAttentionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJGoodsAttentionCell" forIndexPath:indexPath];
        cell.goodrateName.hidden = YES;
        cell.dealName.hidden = YES;
        cell.evaluateLabel.hidden = YES;
        cell.dealCountLabel.hidden = YES;
        
        [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        
        CGSize nameSize = [CZJUtils calculateStringSizeWithString:form.itemName Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 116];
        cell.goodNameLabel.text = form.itemName;
        cell.goodNameLayoutHeight.constant = nameSize.height > 18 ? 36 : 18;
        cell.priceLabel.text = form.currentPrice;
        cell.selectBtn.selected = form.isSelected;

        
        [cell layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            cell.viewLayoutLeading.constant = _isEdit? 30 : 0;
            [cell layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];

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
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"####### %ld",indexPath.row);
    if ([_currentType isEqualToString:@"2"])
    {
        CZJStoreAttentionForm* form = tmpArray[indexPath.row];
        if (self.isEdit)
        {
            form.isSelected = !form.isSelected;
            DLog(@"self.myTableView reloadData");
            [self.myTableView reloadData];
        }
        else
        {
            [CZJUtils showStoreDetailView:self.navigationController andStoreId:form.storeId];
        }
    }
    else
    {
        CZJGoodsAttentionForm* form = tmpArray[indexPath.row];
        if (self.isEdit)
        {
            form.isSelected = !form.isSelected;
            DLog(@"self.myTableView reloadData");
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
    DLog(@"%lu",index);
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [tmpArray removeAllObjects];
    self.myTableView.hidden = YES;
    self.isEdit = NO;
    ((UIButton*)VIEWWITHTAG(self.naviBarView, 1999)).selected = NO;
//    self.buttomView.hidden = !_isEdit;
    [self setButtomViewShowAnimation:_isEdit];
    if (1 == index)
    {
        _currentType = [NSString stringWithFormat:@"%lu",index - 1];
        
    }
    else if (0 == index)
    {
        _currentType = [NSString stringWithFormat:@"%lu",index + 1];

    }
    else
    {
        _currentType =[NSString stringWithFormat:@"%lu",index];
    }
    
    
    if ((!_isServiceTouched && 0 == index) ||
        (!_isGoodsTouched && 1 == index) ||
        (!_isStoreTouched && 2 == index) )
    {
        [refreshFooter resetNoMoreData];
        _getdataType = CZJHomeGetDataFromServerTypeOne;
        page = 1;
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
            if (!_isServiceLoadOver)
            {
                [refreshFooter resetNoMoreData];
            }
            else
            {
                [refreshFooter noticeNoMoreData];
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
            if (!_isGoodsLoadOver)
            {
                [refreshFooter resetNoMoreData];
            }
            else
            {
                [refreshFooter noticeNoMoreData];
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
            if (!_isStoreLoadOver)
            {
                [refreshFooter resetNoMoreData];
            }
            else
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        self.myTableView.hidden = NO;
        DLog(@"self.myTableView reloadData");
        [self.myTableView reloadData];
        self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
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
    if (deleteIdAry.count > 0)
    {
        NSString* ids = [deleteIdAry componentsJoinedByString:@","];
        NSDictionary* params = @{@"type": _currentType, @"ids":ids};
        __weak typeof(self) weakSelf = self;
        NSString* alertStr;
        if (0 == [_currentType integerValue])
        {
            alertStr = [NSString stringWithFormat:@"确认要取消关注这%ld种%@吗?",deleteIdAry.count,@"商品"];
        }
        if (1 == [_currentType integerValue])
        {
            alertStr = [NSString stringWithFormat:@"确认要取消关注这%ld种%@吗?",deleteIdAry.count,@"服务"];
        }
        if (2 == [_currentType integerValue])
        {
            alertStr = [NSString stringWithFormat:@"确认要取消关注这%ld个%@吗?",deleteIdAry.count,@"门店"];
        }
        [self showCZJAlertView:alertStr andConfirmHandler:^{
            [CZJBaseDataInstance cancleAttentionList:params Success:^(id json) {
                [deleteIdAry removeAllObjects];
                [weakSelf getDataAttentionDataFromServer];
                [weakSelf hideWindow];
                [CZJUtils tipWithText:@"取消成功" andView:nil];
            } fail:nil];
        } andCancleHandler:nil];
        
    }
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
    [self pitchOn];
    DLog(@"self.myTableView reloadData");
    [self.myTableView reloadData];
}

- (void)setButtomViewShowAnimation:(BOOL)_isShow
{
    __weak typeof(self) weakSelf = self;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.35 animations:^{
        //遍历查找view的heigh约束，并修改它
        weakSelf.buttomViewButtom.constant = _isShow ? 0 : -50;
        //更新约束  在某个时刻约束会被还原成frame使视图显示
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}
@end
