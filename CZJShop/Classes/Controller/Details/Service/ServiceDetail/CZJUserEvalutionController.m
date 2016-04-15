//
//  CZJUserEvalutionController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJUserEvalutionController.h"
#import "LXDSegmentControl.h"
#import "PullTableView.h"
#import "CZJBaseDataManager.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionDetailCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJUserEvalutionDetailController.h"
#import "CZJAddedEvalutionCell.h"
@interface CZJUserEvalutionController ()
<
LXDSegmentControlDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    NSDictionary* postParams;
    CZJEvaluateForm* currentTouchedEvalutionForm;
    BOOL isFirstLoad;
    
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
}
@property (weak, nonatomic) IBOutlet LXDSegmentControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *myEvalTableView;

@property (nonatomic, strong)NSMutableArray* tmpEvalutionAry;
@property (nonatomic, strong)NSMutableArray* allEvalutionAry;
@property (nonatomic, strong)NSMutableArray* picEvalutionAry;
@property (nonatomic, strong)NSMutableArray* goodEvalutionAry;
@property (nonatomic, strong)NSMutableArray* middleEvalutionAry;
@property (nonatomic, strong)NSMutableArray* badEvalutionAry;

@property (nonatomic, assign)NSInteger currentSelectedSegment;

@end

@implementation CZJUserEvalutionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initTopViews];
    [self loadAllUserEvalutionsDataFromServer];
}

- (void)initDatas
{
    _tmpEvalutionAry = [NSMutableArray array];
    _allEvalutionAry = [NSMutableArray array];
    _picEvalutionAry = [NSMutableArray array];
    _goodEvalutionAry = [NSMutableArray array];
    _middleEvalutionAry = [NSMutableArray array];
    _badEvalutionAry = [NSMutableArray array];
    isFirstLoad = YES;
    
    page = 1;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
}

- (void)initTopViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"评价";
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    
    //segment初始化
    CGRect frame = CGRectMake(15, 10, PJ_SCREEN_WIDTH - 30, 40);
    NSArray * items = @[@"全部", @"有图", @"好评", @"中评", @"差评"];
    LXDSegmentControlConfiguration * select = [LXDSegmentControlConfiguration configurationWithControlType: LXDSegmentControlTypeSelectBlock items: items];
    UIView* segmentView = [LXDSegmentControl segmentControlWithFrame: frame configuration: select delegate: self];
    [self.segmentControl addSubview:segmentView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = true;
    
    //TableView初始化
    NSArray* nibArys = @[@"CZJEvalutionDetailCell",
                         @"CZJEvalutionDescCell",
                         @"CZJEvalutionFooterCell",
                         @"CZJAddedEvalutionCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myEvalTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    self.myEvalTableView.tableFooterView = [[UIView alloc]init];
    self.myEvalTableView.backgroundColor = WHITECOLOR;
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weak loadDataWithType:_currentSelectedSegment  isRefreshType:CZJHomeGetDataFromServerTypeTwo];;
    }];
    self.myEvalTableView.footer = refreshFooter;
    self.myEvalTableView.footer.hidden = YES;
}


-(void)loadDataWithType:(NSInteger)segType  isRefreshType:(CZJHomeGetDataFromServerType)type{
    
    postParams =@{@"counterKey": _counterKey, @"page": @(page),@"type":[NSString stringWithFormat:@"%ld",segType]};
    __weak typeof(self) weakSelf = self;
    CZJSuccessBlock successBlock = ^(id json)
    {
        [self segmentControl:nil didSelectAtIndex:_currentSelectedSegment];
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        DLog(@"%@",[[CZJUtils DataFromJson:json] description]);
        NSArray* formAry = [CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry];
        [_tmpEvalutionAry removeAllObjects];
        if (tmpAry.count < 20)
        {
            [refreshFooter noticeNoMoreData];
        }
        else
        {
            [weakSelf.myEvalTableView.footer endRefreshing];
        }
        switch (_currentSelectedSegment)
        {
            case CZJEvalutionTypeAll:
                [_allEvalutionAry addObjectsFromArray:formAry];
                [_tmpEvalutionAry addObjectsFromArray:_allEvalutionAry];
                break;
                
            case CZJEvalutionTypePic:
                [_picEvalutionAry addObjectsFromArray:formAry];
                [_tmpEvalutionAry addObjectsFromArray:_picEvalutionAry];
                break;
                
            case CZJEvalutionTypeGood:
                [_goodEvalutionAry addObjectsFromArray:formAry];
                [_tmpEvalutionAry addObjectsFromArray:_goodEvalutionAry];
                break;
                
            case CZJEvalutionTypeMiddle:
                [_middleEvalutionAry addObjectsFromArray:formAry];
                [_tmpEvalutionAry addObjectsFromArray:_middleEvalutionAry];
                break;
                
            case CZJEvalutionTypeBad:
                [_badEvalutionAry addObjectsFromArray:formAry];
                [_tmpEvalutionAry addObjectsFromArray:_badEvalutionAry];
                break;
                
            default:
                break;
        }

    };
    [CZJBaseDataInstance loadUserEvalutions:postParams type:type Success:successBlock fail:^{}];
}

- (void)loadAllUserEvalutionsDataFromServer
{
    __block int loginInt = 0;
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < 5; i++)
    {
        CZJSuccessBlock successBlock = ^(id json)
        {
            DLog(@"%@",[[CZJUtils DataFromJson:json] description]);
            loginInt++;
            NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
            switch (i)
            {
                case 0:
                    _allEvalutionAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    break;
                    
                case 1:
                    _picEvalutionAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    break;
                    
                case 2:
                    _goodEvalutionAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    break;
                    
                case 3:
                    _middleEvalutionAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    break;
                    
                case 4:
                    _badEvalutionAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
                    break;
                    
                default:
                    break;
            }
            
            //五次请求数据返回完成后开始加载数据到表格上
            if (loginInt >= 5 && isFirstLoad)
            {
                isFirstLoad = NO;
                [_tmpEvalutionAry addObjectsFromArray: _allEvalutionAry];
                if (_tmpEvalutionAry.count < 10)
                {
                    [refreshFooter noticeNoMoreData];
                }
            
                if (_tmpEvalutionAry.count == 0)
                {
                    weakSelf.myEvalTableView.hidden = YES;
                    [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有浏览记录/(ToT)/~~"];
                }
                else
                {
                    weakSelf.myEvalTableView.hidden = (_tmpEvalutionAry.count == 0);
                    weakSelf.myEvalTableView.delegate = self;
                    weakSelf.myEvalTableView.dataSource = self;
                    [weakSelf.myEvalTableView reloadData];
                    weakSelf.myEvalTableView.footer.hidden = self.myEvalTableView.mj_contentH < self.myEvalTableView.frame.size.height;
                }
            }
        };
        postParams =@{@"counterKey": _counterKey, @"page": @(page),@"type":[NSString stringWithFormat:@"%d",i]};
        [CZJBaseDataInstance loadUserEvalutions:postParams
                                           type:CZJHomeGetDataFromServerTypeOne
                                        Success:successBlock
                                           fail:^{}];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_tmpEvalutionAry.count > 0) {
        return _tmpEvalutionAry.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CZJEvaluateForm* detailEvalForm = (CZJEvaluateForm* )_tmpEvalutionAry[section];
    BOOL isHaveAdded = [detailEvalForm.added boolValue];
    return isHaveAdded ? 4 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%ld",indexPath.section);
    CZJEvaluateForm* detailEvalform = (CZJEvaluateForm*)_tmpEvalutionAry[indexPath.section];
    if (indexPath.row == 0)
    {
        CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCell" forIndexPath:indexPath];
        [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:detailEvalform.head] placeholderImage:IMAGENAMED(@"placeholder_personal")];
        cell.evalWriterName.text = detailEvalform.name;
        cell.evalWriteTime.text = detailEvalform.evalTime;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.row == 1)
    {
        CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
        [cell setStar:[detailEvalform.score intValue]];
        cell.evalTime.text = nil;
        cell.evalWriter.text = nil;
        
        cell.evalContent.text = detailEvalform.message;
        CGSize contenSize = [CZJUtils calculateStringSizeWithString:detailEvalform.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
        cell.evalContentLayoutHeight.constant = contenSize.height;
        cell.picView.hidden = YES;
        [cell.picView removeAllSubViews];
        for (int i = 0; i < detailEvalform.evalImgs.count; i++)
        {
            UIImageView* evaluateImage = [[UIImageView alloc]init];
            [evaluateImage sd_setImageWithURL:[NSURL URLWithString:detailEvalform.evalImgs[i]] placeholderImage:DefaultPlaceHolderSquare];
            CGRect iamgeRect = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 10) size:CGSizeMake(78, 78) index:i divide:Divide];
            evaluateImage.frame = iamgeRect;
            [cell.picView addSubview:evaluateImage];
            cell.picView.hidden = NO;
        }
        cell.separatorInset = HiddenCellSeparator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if ([detailEvalform.added boolValue] && 2 == indexPath.row)
    {
        CZJAddedEvalutionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddedEvalutionCell" forIndexPath:indexPath];
        cell.addedTimeLabel.text = detailEvalform.addedEval.evalTime;
        cell.addedContentLabel.text = detailEvalform.addedEval.message;
        float strHeight = [CZJUtils calculateStringSizeWithString:detailEvalform.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
        cell.contentLabelHeight.constant = strHeight + 5;
        
        for (int i = 0; i < detailEvalform.addedEval.evalImgs.count; i++)
        {
            NSString* url = detailEvalform.addedEval.evalImgs[i];
            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(70, 70) index:i divide:Divide];
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:imageFrame];
            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DefaultPlaceHolderSquare];
            [cell.picView addSubview:imageView];
        }

        return cell;
    }
    if (([detailEvalform.added boolValue] && 3 == indexPath.row)||
        (![detailEvalform.added boolValue] && 2 == indexPath.row))
    {
        CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
        [cell setVisibleView:kEvalDetailView];
        cell.delegate = self;
        cell.addEvaluateBtn.hidden = YES;
        cell.serviceName.text = detailEvalform.itemName;
        cell.serviceTime.text = detailEvalform.orderTime;
        cell.form = detailEvalform;
        [cell.evalutionReplyBtn setTitle:[NSString stringWithFormat:@"(%@)",detailEvalform.replyCount] forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = HiddenCellSeparator;
        return cell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJEvaluateForm* evalutionForm  = (CZJEvaluateForm*)_tmpEvalutionAry[indexPath.section];
    if (0 == indexPath.row) {
        return 46;
    }
    if (1 == indexPath.row) {
        //这里是动态改变的，暂时设一个固定值
        
        CGSize contenSize = [CZJUtils calculateStringSizeWithString:evalutionForm.message Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 40];
        NSInteger row = 1;
        NSInteger cellHeight = 60 + (contenSize.height > 20 ? contenSize.height : 20) + row * 88;
        return cellHeight;
    }
    if (2 == indexPath.row && [evalutionForm.added boolValue])
    {
        float strHeight = [CZJUtils calculateStringSizeWithString:evalutionForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40].height;
        float picViewHeight = 0;
        if (evalutionForm.addedEval.evalImgs.count != 0)
        {
            picViewHeight = 70;
        }
        return 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
    }
    if ((2 == indexPath.row && ![evalutionForm.added boolValue])||
        (3 == indexPath.row && [evalutionForm.added boolValue]))
    {
        return 64;
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
    currentTouchedEvalutionForm = (CZJEvaluateForm*)_tmpEvalutionAry[indexPath.section];
    [self performSegueWithIdentifier:@"segueToUserEvalutionDetail" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //去掉tableview中section的headerview粘性
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark- LXDSegmentControlDelegate
- (void)segmentControl: (LXDSegmentControl *)segmentControl didSelectAtIndex: (NSUInteger)index
{
    if (!isFirstLoad)
    {
        [CZJUtils removeNoDataAlertViewFromTarget:self.view];
        _currentSelectedSegment = index;
        [self reloadTableview];
    }
}

- (void)reloadTableview
{
    [_tmpEvalutionAry removeAllObjects];
    switch (_currentSelectedSegment) {
        case CZJEvalutionTypeAll:
            [_tmpEvalutionAry addObjectsFromArray:_allEvalutionAry];
            break;
            
        case CZJEvalutionTypePic:
            [_tmpEvalutionAry addObjectsFromArray:_picEvalutionAry];
            break;
            
        case CZJEvalutionTypeGood:
            [_tmpEvalutionAry addObjectsFromArray:_goodEvalutionAry];
            break;
            
        case CZJEvalutionTypeMiddle:
            [_tmpEvalutionAry addObjectsFromArray:_middleEvalutionAry];
            break;
            
        case CZJEvalutionTypeBad:
            [_tmpEvalutionAry addObjectsFromArray:_badEvalutionAry];
            break;
            
        default:
            break;
    }
    if (_tmpEvalutionAry.count == 0)
    {
        self.myEvalTableView.hidden = YES;
        [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有对应评价/(ToT)/~~"];
    }
    else
    {
        [CZJUtils removeNoDataAlertViewFromTarget:self.view];
        self.myEvalTableView.hidden = NO;
        [self.myEvalTableView setContentOffset:CGPointZero];
        [self.myEvalTableView reloadData];
    }
}


#pragma mark- CZJImageViewTouchDelegate
- (void)showDetailInfoWithForm:(id)form
{
    currentTouchedEvalutionForm = (CZJEvaluateForm*)form;
    [self performSegueWithIdentifier:@"segueToUserEvalutionDetail" sender:self];
}


#pragma mark- CZJNaviagtionBarViewDelegate
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToUserEvalutionDetail"])
    {
        CZJUserEvalutionDetailController* detailcontroller = segue.destinationViewController;
        detailcontroller.evalutionForm = currentTouchedEvalutionForm;
    }
}
@end
