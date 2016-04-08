//
//  CZJMyEvaluationController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyEvaluationController.h"
#import "CZJBaseDataManager.h"
#import "CZJEvalutionFooterCell.h"
#import "CZJEvalutionDescCell.h"
#import "CZJAddedEvalutionCell.h"
#import "CZJAddMyEvalutionController.h"
@interface CZJMyEvaluationController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* myEvaluationAry;
    
    MJRefreshAutoNormalFooter* refreshFooter;
    __block CZJHomeGetDataFromServerType _getdataType;
    __block NSInteger page;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMyEvaluationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initTableView];
    [self getMyEvalutionDataFromServer];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"我的评价";
    
}

- (void)initMyDatas
{
    myEvaluationAry = [NSMutableArray array];
    page = 1;
    _getdataType = CZJHomeGetDataFromServerTypeOne;
}

- (void)initTableView
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = CLEARCOLOR;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJEvalutionFooterCell",
                         @"CZJEvalutionDescCell",
                         @"CZJAddedEvalutionCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    __weak typeof(self) weak = self;
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^(){
        _getdataType = CZJHomeGetDataFromServerTypeTwo;
        page++;
        [weak getMyEvalutionDataFromServer];;
    }];
    self.myTableView.footer = refreshFooter;
    self.myTableView.footer.hidden = YES;
}

- (void)getMyEvalutionDataFromServer
{
    NSDictionary* param = @{@"page":@(page)};
    __weak typeof(self) weak = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJBaseDataInstance generalPost:param success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        DLog(@"myEvalution:%@",[[CZJUtils DataFromJson:json] description]);
        NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        if (CZJHomeGetDataFromServerTypeTwo == _getdataType)
        {
            [myEvaluationAry addObjectsFromArray: [CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry]];
            if (tmpAry.count < 20)
            {
                [refreshFooter noticeNoMoreData];
            }
            else
            {
                [weak.myTableView.footer endRefreshing];
            }
        }
        else
        {
            myEvaluationAry = [[CZJEvaluateForm objectArrayWithKeyValuesArray:tmpAry] mutableCopy];
            if (myEvaluationAry.count < 10)
            {
                [refreshFooter noticeNoMoreData];
            }
        }
        
        
        if (myEvaluationAry.count == 0)
        {
            self.myTableView.hidden = YES;
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有评价记录/(ToT)/~~"];
        }
        else
        {
            self.myTableView.hidden = (myEvaluationAry.count == 0);
            self.myTableView.delegate = self;
            self.myTableView.dataSource = self;
            [self.myTableView reloadData];
            self.myTableView.footer.hidden = self.myTableView.mj_contentH < self.myTableView.frame.size.height;
        }
        
    }  fail:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CZJUtils showReloadAlertViewOnTarget:weak.view withReloadHandle:^{
            [weak getMyEvalutionDataFromServer];
        }];
    } andServerAPI:kCZJServerAPIMyEvalutions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return myEvaluationAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CZJEvaluateForm* evaluationForm = myEvaluationAry[section];

    return [evaluationForm.added boolValue] ? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJEvaluateForm* evaluationForm = myEvaluationAry[indexPath.section];
    if (0 == indexPath.row)
    {
        CZJEvalutionDescCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionDescCell" forIndexPath:indexPath];
        [cell setStar:[evaluationForm.score intValue]];
        cell.arrowNextImage.hidden = YES;
        cell.evalTime.text = evaluationForm.evalTime;
        float strHeight = [CZJUtils calculateStringSizeWithString:evaluationForm.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
        cell.evalContent.text = evaluationForm.message;
        cell.evalContentLayoutHeight.constant = strHeight + 5;
        cell.picView.hidden = YES;
        
        for (int i = 0; i < evaluationForm.evalImgs.count; i++)
        {
            NSString* url = evaluationForm.evalImgs[i];
            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(78, 78) index:i divide:Divide];
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:imageFrame];
            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DefaultPlaceHolderImage];
            [cell.picView addSubview:imageView];
            cell.picView.hidden = NO;
        }
        return cell;
    }
    if (1 == indexPath.row)
    {
        
        CZJEvalutionFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJEvalutionFooterCell" forIndexPath:indexPath];
        cell.evalutionReplyBtn.hidden = YES;
        [cell.evalutionReplyBtn setTag:indexPath.section];

        cell.addEvaluateBtn.hidden = YES;
        if (![evaluationForm.added boolValue])
        {
            cell.addEvaluateBtn.hidden = NO;
            [cell.addEvaluateBtn addTarget:self action:@selector(addEvaluateBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.serviceName.text = evaluationForm.itemName;
        cell.serviceTime.text = evaluationForm.orderTime;
        return cell;
    }
    if (2 == indexPath.row)
    {
        
        CZJAddedEvalutionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJAddedEvalutionCell" forIndexPath:indexPath];
        cell.addedTimeLabel.text = evaluationForm.addedEval.evalTime;
        cell.addedContentLabel.text = evaluationForm.addedEval.message;
        float strHeight = [CZJUtils calculateStringSizeWithString:evaluationForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
        cell.addedContentLabel.text = evaluationForm.addedEval.message;
        cell.contentLabelHeight.constant = strHeight + 5;
        
        
        for (int i = 0; i < evaluationForm.addedEval.evalImgs.count; i++)
        {
            NSString* url = evaluationForm.addedEval.evalImgs[i];
            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(0, 0) size:CGSizeMake(70, 70) index:i divide:Divide];
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:imageFrame];
            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:DefaultPlaceHolderImage];
            [cell.picView addSubview:imageView];
        }
        return cell;
    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJEvaluateForm* evaluationForm = myEvaluationAry[indexPath.section];
    if (0 == indexPath.row)
    {
        float strHeight = [CZJUtils calculateStringSizeWithString:evaluationForm.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 30].height;
        float picViewHeight = 0;
        if (evaluationForm.evalImgs.count != 0)
        {
            picViewHeight = 78*(evaluationForm.evalImgs.count / Divide + 1);
        }
        return 50 + 15 + strHeight + 5 + picViewHeight ;
    }
    if (1 == indexPath.row)
    {
        return 60;
    }
    if (2 == indexPath.row)
    {
        float strHeight = [CZJUtils calculateStringSizeWithString:evaluationForm.addedEval.message Font:SYSTEMFONT(13) Width:PJ_SCREEN_WIDTH - 40].height;
        float picViewHeight = 0;
        if (evaluationForm.addedEval.evalImgs.count != 0)
        {
            picViewHeight = 70*(evaluationForm.addedEval.evalImgs.count / Divide + 1);
        }
        return 30 + 10 + strHeight + 5 + picViewHeight + 10 + 15;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (void)addEvaluateBtnHandler:(UIButton*)sender
{
    CZJEvaluateForm* evaluationForm = myEvaluationAry[sender.tag];
    [self performSegueWithIdentifier:@"segueToAddEvaluation" sender:evaluationForm];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToAddEvaluation"])
    {
        CZJAddMyEvalutionController* addEvaluVC = segue.destinationViewController;
        addEvaluVC.currentEvaluation = sender;
    }
}

@end
