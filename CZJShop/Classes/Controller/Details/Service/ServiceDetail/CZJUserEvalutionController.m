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
#import "CZJDetailForm.h"
#import "CZJEvalutionDescCell.h"
#import "CZJEvalutionDetailCell.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJUserEvalutionDetailController.h"
@interface CZJUserEvalutionController ()
<
LXDSegmentControlDelegate,
PullTableViewDelegate,
CZJImageViewTouchDelegate,
CZJNaviagtionBarViewDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableDictionary* postParams;
    CZJEvalutionsForm* currentTouchedEvalutionForm;
}
@property (weak, nonatomic) IBOutlet CZJNaviagtionBarView *topNaviBarView;
@property (weak, nonatomic) IBOutlet LXDSegmentControl *segmentControl;
@property (weak, nonatomic) IBOutlet PullTableView *myEvalTableView;

@property (nonatomic, strong)NSMutableArray* tmpEvalutionAry;
@property (nonatomic, strong)NSMutableArray* allEvalutionAry;
@property (nonatomic, strong)NSMutableArray* picEvalutionAry;
@property (nonatomic, strong)NSMutableArray* goodEvalutionAry;
@property (nonatomic, strong)NSMutableArray* middleEvalutionAry;
@property (nonatomic, strong)NSMutableArray* badEvalutionAry;

@property (nonatomic, assign)NSInteger currentSelectedSegment;
@property (nonatomic, assign)int page;

@end

@implementation CZJUserEvalutionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initTopViews];
    [self firstLoadAllTypeCommentsDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_topNaviBarView refreshShopBadgeLabel];
}

- (void)initDatas
{
    _tmpEvalutionAry = [NSMutableArray array];
    _allEvalutionAry = [NSMutableArray array];
    _picEvalutionAry = [NSMutableArray array];
    _goodEvalutionAry = [NSMutableArray array];
    _middleEvalutionAry = [NSMutableArray array];
    _badEvalutionAry = [NSMutableArray array];
    
    self.page = 1;
    postParams = [NSMutableDictionary dictionary];
    
}

- (void)initTopViews
{
    CGRect mainViewBounds = self.navigationController.navigationBar.bounds;
    CGRect viewBounds = CGRectMake(0, 0, mainViewBounds.size.width, 52);
    [self.topNaviBarView initWithFrame:viewBounds AndType:CZJNaviBarViewTypeDetail].delegate = self;
    [self.topNaviBarView setBackgroundColor:RGBA(239, 239, 239, 0)];
    
    //segment初始化
    CGRect frame = CGRectMake(15, 10, PJ_SCREEN_WIDTH - 30, 45);
    NSArray * items = @[@"全部100", @"有图90", @"好评90", @"中评70", @"差评10"];
    LXDSegmentControlConfiguration * select = [LXDSegmentControlConfiguration configurationWithControlType: LXDSegmentControlTypeSelectBlock items: items];
    UIView* segmentView = [LXDSegmentControl segmentControlWithFrame: frame configuration: select delegate: self];
    [self.segmentControl addSubview:segmentView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = true;
    
    //TableView初始化
    UINib *nib1=[UINib nibWithNibName:@"CZJEvalutionDetailCell" bundle:nil];
    UINib *nib2=[UINib nibWithNibName:@"CZJEvalutionDescCell" bundle:nil];
    UINib *nib3=[UINib nibWithNibName:@"CZJEvalutionFooterCell" bundle:nil];
    [self.myEvalTableView registerNib:nib1 forCellReuseIdentifier:@"CZJEvalutionDetailCell"];
    [self.myEvalTableView registerNib:nib2 forCellReuseIdentifier:@"CZJEvalutionDescCell"];
    [self.myEvalTableView registerNib:nib3 forCellReuseIdentifier:@"CZJEvalutionFooterCell"];
}

- (void)firstLoadAllTypeCommentsDataFromServer
{
    __block int loadint = 0;
    [postParams setValue:@(self.page) forKey:@"page"];
    CZJSuccessBlock successBlock = ^(id json)
    {
        loadint++;
        //五次请求数据返回完成后开始加载数据到表格上
        if (loadint >= 5) {
            _allEvalutionAry = [[CZJBaseDataInstance detailsForm] userEvalutionAllForms];
            _picEvalutionAry = [[CZJBaseDataInstance detailsForm] userEvalutionWithPicForms];
            _middleEvalutionAry = [[CZJBaseDataInstance detailsForm] userEvalutionMiddleForms];
            _badEvalutionAry = [[CZJBaseDataInstance detailsForm] userEvalutionBadForms];
            _goodEvalutionAry = [[CZJBaseDataInstance detailsForm] userEvalutionGoodForms];
            _tmpEvalutionAry = _allEvalutionAry;
            self.myEvalTableView.delegate = self;
            self.myEvalTableView.dataSource = self;
            self.myEvalTableView.pullDelegate = self;
            [self.myEvalTableView reloadData];
        }
    };
    
    for (int i = 0; i < 5; i++)
    {
        [CZJBaseDataInstance loadUserEvalutions:postParams
                                           type:0
                                        SegType:i
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CZJEvalutionsForm* form = (CZJEvalutionsForm*)_tmpEvalutionAry[indexPath.section];
    if (indexPath.row == 0)
    {
        CZJEvalutionDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDetailCell" forIndexPath:indexPath];
        [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:form.evalHead] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
        cell.evalWriterName.text = form.evalName;
        cell.evalWriteTime.text = form.evalTime;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.row == 1)
    {
        CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
        [cell setStar:[form.evalStar intValue]];
        CGSize contenSize = [form.evalDesc boundingRectWithSize:CGSizeMake(PJ_SCREEN_WIDTH - 40, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: SYSTEMFONT(13)} context:nil].size;
        cell.evalContentLayoutHeight.constant = contenSize.height;
        cell.evalContent.text = form.evalDesc;
        cell.evalTime.text = nil;
        cell.evalWriter.text = nil;
        NSInteger count = form.imgs.count;
        
        CGRect imagerect = cell.addtionnalImage.frame;
        for (int i = 0; i<count; i++)
        {
            UIImageView* image = [[UIImageView alloc]init];
            [image sd_setImageWithURL:[NSURL URLWithString:form.imgs[i]] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
            image.layer.cornerRadius = 2;
            image.clipsToBounds = YES;
            int divide = 4;
            // 列数
            int column = i%divide;
            // 行数
            int row = i/divide;
            DLog(@"row:%d, column:%d", row, column);
            // 很据列数和行数算出x、y
            int childX = column * (imagerect.size.width + 10);
            int childY = row * imagerect.size.height;
            image.frame = CGRectMake(20 + childX , childY + contenSize.height + 40, imagerect.size.width, imagerect.size.height);
            [cell addSubview:image];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (2 == indexPath.row)
    {
        CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
        [cell setVisibleView:kEvalDetailView];
        cell.serviceName.text = form.purchaseItem;
        cell.serviceTime.text = form.purchaseTime;
        cell.form = form;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return 46;
    }
    if (1 == indexPath.row) {
        //这里是动态改变的，暂时设一个固定值
        return 160;
    }
    if (2 == indexPath.row)
    {
        return 64;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentTouchedEvalutionForm = (CZJEvalutionsForm*)_tmpEvalutionAry[indexPath.section];
    [self performSegueWithIdentifier:@"segueToUserEvalutionDetail" sender:self];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.1f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreToTable) withObject:nil afterDelay:0.1f];
}

- (void)refreshTable
{
    self.page=1;
    [self loadDataWithType:_currentSelectedSegment isRefreshType:CZJHomeGetDataFromServerTypeOne];
}

- (void)loadMoreToTable
{
    self.page++;
    [self loadDataWithType:_currentSelectedSegment isRefreshType:CZJHomeGetDataFromServerTypeTwo];
}

NSInteger customSort(CZJEvalutionsForm* obj1, CZJEvalutionsForm* obj2,void* context){
    if ([obj1 evalutionId] > [obj2 evalutionId]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 evalutionId] < [obj2 evalutionId]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
}

-(void)loadDataWithType:(NSInteger)segType  isRefreshType:(CZJHomeGetDataFromServerType)type{
    
    [postParams setValue:@(self.page) forKey:@"page"];
    CZJSuccessBlock successBlock = ^(id json)
    {
        [self segmentControl:nil didSelectAtIndex:_currentSelectedSegment];

        [self.myEvalTableView reloadData];
        
        switch (type) {
            case CZJHomeGetDataFromServerTypeOne:
            {
                DLog(@"Get Home Data From Server Success...");
                [self.myEvalTableView reloadData];
                
                if (self.myEvalTableView.pullTableIsRefreshing == YES)
                {
                    self.myEvalTableView.pullLastRefreshDate = [NSDate date];
                }
                self.myEvalTableView.pullTableIsLoadingMore = NO;
                self.myEvalTableView.pullTableIsRefreshing = NO;
            }
                break;
                
            case CZJHomeGetDataFromServerTypeTwo:
            {
                DLog(@"Get Goods Data From Server Success...");
                [self.myEvalTableView reloadData];
                if (self.myEvalTableView.pullTableIsRefreshing == YES)
                {
                    self.myEvalTableView.pullLastRefreshDate = [NSDate date];
                }
                self.myEvalTableView.pullTableIsLoadingMore = NO;
                self.myEvalTableView.pullTableIsRefreshing = NO;
                
            }
                break;
                
            default:
                break;
        }
    };
    [CZJBaseDataInstance loadUserEvalutions:postParams
                                           type:0
                                        SegType:_currentSelectedSegment
                                        Success:successBlock
                                           fail:^{}];
}




#pragma mark- LXDSegmentControlDelegate
- (void)segmentControl: (LXDSegmentControl *)segmentControl didSelectAtIndex: (NSUInteger)index
{
    DLog(@"select segment:%ld",index);
    _currentSelectedSegment = index;
    [self.myEvalTableView setContentOffset:CGPointZero];
    [self reloadTableview];
}

- (void)reloadTableview
{
    switch (_currentSelectedSegment) {
        case CZJEvalutionTypeAll:
            _tmpEvalutionAry = _allEvalutionAry;
            break;
            
        case CZJEvalutionTypePic:
            _tmpEvalutionAry = _picEvalutionAry;
            break;
            
        case CZJEvalutionTypeGood:
            _tmpEvalutionAry = _goodEvalutionAry;
            break;
            
        case CZJEvalutionTypeMiddle:
            _tmpEvalutionAry = _middleEvalutionAry;
            break;
            
        case CZJEvalutionTypeBad:
            _tmpEvalutionAry = _badEvalutionAry;
            break;
            
        default:
            break;
    }
    [self.myEvalTableView reloadData];
}


#pragma mark- CZJImageViewTouchDelegate
- (void)showDetailInfoWithForm:(id)form
{
    currentTouchedEvalutionForm = (CZJEvalutionsForm*)form;
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
