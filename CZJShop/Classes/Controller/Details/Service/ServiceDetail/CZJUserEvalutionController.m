//
//  CZJUserEvalutionController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJUserEvalutionController.h"
#import "CZJNaviagtionBarView.h"
#import "LXDSegmentControl.h"
#import "PullTableView.h"
#import "UIImageView+WebCache.h"
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
CZJImageViewTouchDelegate
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
    [self initTopViews];
    [self initDatas];
    // Do any additional setup after loading the view.
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
    //segment初始化
    CGRect frame = CGRectMake(0, 0, PJ_SCREEN_WIDTH- 30.f, 44.f);
    NSArray * items = @[@"全部", @"有图", @"好评", @"中评", @"差评"];
    LXDSegmentControlConfiguration * select = [LXDSegmentControlConfiguration configurationWithControlType: LXDSegmentControlTypeSelectBlock items: items];
    self.segmentControl = [LXDSegmentControl segmentControlWithFrame: frame configuration: select delegate: self];
//    self.segmentControl.center = (CGPoint){ self.view.center.x, self.view.center.y };
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //TableView初始化
    self.myEvalTableView.delegate = self;
    self.myEvalTableView.dataSource = self;
    
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
    // Dispose of any resources that can be recreated.
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
        [cell.evalWriteHeadImage sd_setImageWithURL:[NSURL URLWithString:form.evalHead] placeholderImage:nil];
        cell.evalWriterName.text = form.evalName;
        cell.evalWriteTime.text = form.evalTime;
        return cell;
    }
    if (indexPath.row == 1)
    {
        CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
        [cell setStar:[form.evalStar intValue]];
        cell.evalContent.text = form.evalDesc;
        cell.evalTime.text = nil;
        cell.evalWriter.text = nil;
        NSInteger count = form.imgs.count;
        
        CGRect imagerect = cell.addtionnalImage.frame;
        for (int i = 0; i<count; i++)
        {
            UIImageView* image = [[UIImageView alloc]init];
            [image sd_setImageWithURL:[NSURL URLWithString:form.imgs[i]] placeholderImage:nil];
            
            int divide = 4;
            // 列数
            int column = i%divide;
            // 行数
            int row = i/divide;
            DLog(@"row:%d, column:%d", row, column);
            // 很据列数和行数算出x、y
            int childX = column * imagerect.size.width;
            int childY = row * imagerect.size.height;
            image.frame = CGRectMake(childX , childY, imagerect.size.width, imagerect.size.height);
            [cell addSubview:image];
        }
        return cell;
    }
    if (2 == indexPath.row)
    {
        CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
        [cell setVisibleView:kEvalDetailView];
        cell.serviceName.text = form.purchaseItem;
        cell.serviceTime.text = form.purchaseTime;
        cell.form = form;
        return cell;
    }
    return nil;
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

/**
 *  @brief 刷新数据表
 *
 */
- (void)refreshTable
{
    self.page=1;
    [self loadDataWithType:_currentSelectedSegment isRefreshType:CZJHomeGetDataFromServerTypeOne];
}

/**
 *  @brief 载入更多
 *
 */
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

-(void)loadDataWithType:(int)segType  isRefreshType:(CZJHomeGetDataFromServerType)type{
    
    [postParams setValue:@(self.page) forKey:@"page"];
    CZJSuccessBlock successBlock = ^(id json)
    {
        [self segmentControl:nil didSelectAtIndex:_currentSelectedSegment];

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


#pragma mark-CZJImageViewTouchDelegate
- (void)showDetailInfoWithForm:(id)form
{
    currentTouchedEvalutionForm = (CZJEvalutionsForm*)form;
    [self performSegueWithIdentifier:@"segueToUserEvalutionDetail" sender:self];
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
