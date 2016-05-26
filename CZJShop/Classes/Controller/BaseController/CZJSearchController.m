//
//  CZJSearchController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/25/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJSearchController.h"
#import "NIDropDown.h"
#import "CZJServiceListController.h"
#import "CZJGoodsListController.h"
#import "CZJStoreViewController.h"
#import "CZJBaseDataManager.h"

@interface CZJSearchController ()
<
NIDropDownDelegate,
UIGestureRecognizerDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    NIDropDown *dropDown;
    NSMutableArray* searchHistoryAry;
    NSMutableArray* currentAry;
    SearchType searchType;
    BOOL isCancel;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIView *clearHisView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

- (IBAction)cancelSerchAction:(id)sender;
- (IBAction)clearHistoryAction:(id)sender;
- (IBAction)chooseCategoryAction:(id)sender;

@end

@implementation CZJSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
}

- (void)initDatas
{
    searchHistoryAry = [NSMutableArray array];
    currentAry = [NSMutableArray array];
    searchType = kSearchTypeHistory;
    isCancel = YES;
}

- (void)initViews
{
    self.searchView.layer.borderColor = RGB(240, 240, 240).CGColor;
    self.searchView.layer.borderWidth = 0.5;
    self.searchView.clipsToBounds = YES;
    CGPoint pt = CGPointMake(self.categoryLabel.origin.x + self.categoryLabel.size.width, self.categoryLabel.origin.y + self.categoryLabel.size.height * 0.5);
    CAShapeLayer *indicator = [CZJUtils creatIndicatorWithColor:[UIColor grayColor] andPosition:pt];
    [self.searchView.layer addSublayer:indicator];
    
    //背景触摸层
    _backgroundView.backgroundColor = RGBA(100, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;

    //搜索记录TableView
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
    self.myTableView.tableFooterView = [[UIView alloc] init];
    self.myTableView.hidden = YES;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.clearHisView.hidden = YES;
    
    //读取搜索历史记录文件，如果有历史记录，则显示出来。
    searchHistoryAry = [CZJUtils readArrayFromDocumentsDirectoryWithName:kCZJPlistFileSearchHistory];
    if (searchHistoryAry.count > 0)
    {
        self.myTableView.hidden = NO;
        [self.myTableView reloadData];
    }
    
    //输入框注册回调事件
    [self.searchTextField addTarget:self action:@selector(textFieldDidReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.searchTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.searchTextField becomeFirstResponder];
    
    

}

- (void)setDetailType:(CZJDetailType)detailType
{
    _detailType = detailType;
    //默认搜索标签为服务
    switch (self.detailType)
    {
        case CZJDetailTypeService:
            self.categoryLabel.text = @"服务";
            break;
        case CZJDetailTypeGoods:
            self.categoryLabel.text = @"商品";
            break;
        case CZJDetailTypeStore:
            self.categoryLabel.text = @"门店";
            break;
            
        default:
            break;
    }
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
    if (searchType == kSearchTypeServer)
    {
        return currentAry.count;
    }
    if (searchType == kSearchTypeHistory && searchHistoryAry.count > 0)
    {
        return searchHistoryAry.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    if (searchHistoryAry.count == indexPath.row && searchType == kSearchTypeHistory)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"clearCell"];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = CZJREDCOLOR;
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = SYSTEMFONT(15);
            [button addTarget:self action:@selector(clearHistoryAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"清除历史记录" forState:UIControlStateNormal];
            button.layer.cornerRadius = 2.5;
            CGRect btnFrame = CGRectMake(50, 30, PJ_SCREEN_WIDTH - 100, 40);
            button.frame = btnFrame;
            [cell addSubview:button];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"searchCell"];
            cell.detailTextLabel.font = SYSTEMFONT(13);
            cell.textLabel.font = SYSTEMFONT(14);
            UIView* sepview = [[UIView alloc]initWithFrame:CGRectMake(20, cell.frame.size.height, PJ_SCREEN_WIDTH - 20, 0.5)];
            sepview.backgroundColor = RGB(230, 230, 230);
            [cell addSubview:sepview];
            
        }
    }


    if (searchType == kSearchTypeServer)
    {
        NSDictionary* dict = currentAry[indexPath.row];
        if (dict)
        {
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.text = [dict valueForKey:@"numFound"];
            cell.textLabel.text = [dict valueForKey:@"kw"];
        }
    }
    if (searchType == kSearchTypeHistory)
    {
        if (searchHistoryAry.count == indexPath.row && searchType == kSearchTypeHistory)
        {
        }
        else
        {
            cell.textLabel.text = searchHistoryAry[indexPath.row];
            cell.detailTextLabel.text = @"";
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchType == kSearchTypeHistory && searchHistoryAry.count == indexPath.row)
    {
        return 100;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchType == kSearchTypeServer) {
        NSString* str = [currentAry[indexPath.row] valueForKey:@"kw"];
        [searchHistoryAry insertObject:str atIndex:0];
        for (int i = 1; i < searchHistoryAry.count; i++)
        {
            if ([searchHistoryAry[i] isEqualToString:str])
            {
                [searchHistoryAry removeObjectAtIndex:i];
                continue;
            }
        }
        [CZJUtils writeArrayToDocumentsDirectory:searchHistoryAry withPlistName:kCZJPlistFileSearchHistory];
        [self beginSearch:str];
    }
    else if (searchType == kSearchTypeHistory &&  indexPath.row < searchHistoryAry.count)
    {
        [self beginSearch:searchHistoryAry[indexPath.row]];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

#pragma mark- NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    if ([btnStr isEqualToString:@"服务"])
    {
        _detailType = CZJDetailTypeService;
    }
    if ([btnStr isEqualToString:@"商品"])
    {
        _detailType = CZJDetailTypeGoods;
    }
    if ([btnStr isEqualToString:@"门店"])
    {
        _detailType = CZJDetailTypeStore;
    }
    self.categoryLabel.text = btnStr;
    [self tapBackground:nil];
}


- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (IBAction)cancelSerchAction:(id)sender
{
    if (isCancel)
    {
        [self.view endEditing:YES];
        [self.delegate didCancel:self];
    }
    else
    {
        [self.view endEditing:YES];
        isCancel = YES;
//        [self textFieldDidReturn:_searchTextField];
        [self beginSearch:_searchTextField.text];
        if (![_searchTextField.text isEqualToString:@""]) {
            [searchHistoryAry insertObject:_searchTextField.text atIndex:0];
            [CZJUtils writeArrayToDocumentsDirectory:searchHistoryAry withPlistName:kCZJPlistFileSearchHistory];
        }
    }
    
}

- (IBAction)clearHistoryAction:(id)sender
{
    [self.searchTextField resignFirstResponder];
    [self showCZJAlertView:@"确定清除搜索记录？" andConfirmHandler:^{
        [searchHistoryAry removeAllObjects];
        [CZJUtils writeArrayToDocumentsDirectory:searchHistoryAry withPlistName:kCZJPlistFileSearchHistory];
        [self.myTableView reloadData];
        [self hideWindow];
        [self.searchTextField becomeFirstResponder];
    } andCancleHandler:^{
        [self.searchTextField becomeFirstResponder];
    }];
}

- (IBAction)chooseCategoryAction:(id)sender
{
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@{@"服务" : @"shop_icon_serve"}, @{@"商品":@"shop_icon_goods"}, @{@"门店" :@"prodetail_icon_shop02"},nil];
    if(dropDown == nil) {
        CGRect rect = CGRectMake(15, StatusBar_HEIGHT + 68, 120, 150);
        _backgroundView.hidden = NO;
        dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr andType:CZJNIDropDownTypeNormal];
        [dropDown setTrangleLayerPositioin:kCZJLayerPositionTypeLeft];
        dropDown.delegate = self;
    }
}

- (void)beginSearch:(NSString*)searchStr
{
    CZJViewController* vc;
    switch (_detailType) {
        case CZJDetailTypeService:
        {
            vc = (CZJServiceListController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"serviceListSBID"];
            vc.typeId = @"";
        }
            break;
        case CZJDetailTypeGoods:
        {
            vc = (CZJGoodsListController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"goodListSBID"];
            vc.typeId = @"";
        }
            break;
        case CZJDetailTypeStore:
        {
            vc = (CZJStoreViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"storeListSBID"];
            vc.hidesBottomBarWhenPushed = YES;
        }
            break;
            
        default:
            break;
    }
    [self cancelSerchAction:nil];

    [self.view endEditing:YES];
    if ([self.parent isKindOfClass:[UIViewController class]])
    {
        vc.searchStr = searchStr;
        UIViewController* control = (UIViewController*)self.parent;
        [control.navigationController pushViewController:vc animated:true];
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidReturn:(UITextField *)textField
{
    DLog(@"%@",textField.text);
    [self.searchTextField resignFirstResponder];
    [self beginSearch:textField.text];
    if (![textField.text isEqualToString:@""]) {
        [searchHistoryAry insertObject:textField.text atIndex:0];
        [CZJUtils writeArrayToDocumentsDirectory:searchHistoryAry withPlistName:kCZJPlistFileSearchHistory];
    }
}

- (void)textFieldDidChanged:(UITextField *)textField
{
    DLog(@"%@",textField.text);
    if (![CZJUtils isBlankString:textField.text])
    {
        isCancel = NO;
        [self.cancelBtn setTitle:@"搜索" forState:UIControlStateNormal];
    }
    else
    {
        isCancel = YES;
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    }
    
    if ([textField.text isEqualToString:@""])
    {
        searchType = kSearchTypeHistory;
        [self.myTableView reloadData];
    }
    else
    {
        searchType = kSearchTypeServer;
        //模糊搜索
        NSDictionary* params = @{@"q":textField.text};
        [CZJBaseDataInstance searchAnything:params Success:^(id json) {
            [currentAry removeAllObjects];
            currentAry = [[[CZJUtils DataFromJson:json] valueForKey:@"msg"]mutableCopy];
            if (currentAry.count > 0)
            {
                self.myTableView.hidden = NO;
                [self.myTableView reloadData];
            }
        } fail:^{
            
        }];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}
@end
