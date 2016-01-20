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

@interface CZJMyInfoAttentionController ()
<
CZJNaviagtionBarViewDelegate,
LXDSegmentControlDelegate,
PullTableViewDelegate,
UIGestureRecognizerDelegate
>
{
    NSString* _currentType;
}
@property (weak, nonatomic) IBOutlet PullTableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepratorViewHeight;


- (IBAction)deleteAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;

@end

@implementation CZJMyInfoAttentionController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sepratorViewHeight.constant = 0.5;
    [self addCZJNaviBarView];
    self.naviBarView.delegate = self;
    [self initDatas];
    [self initViews];
}

- (void)initDatas
{
}

- (void)initViews
{
    [CZJUtils customizeNavigationBarForTarget:self];
    //右按钮
    UIButton *rightBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(0 , 0 , 44 , 44 )];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitle:@"完成" forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn setSelected:NO];
    rightBtn.titleLabel.font = SYSTEMFONT(16);
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: rightBtn];
    if ((IS_IOS7 ? 20 : 0))
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = 0 ;//这个数值可以根据情况自由变化
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
        
    } else
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
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
    [CZJBaseDataInstance loadMyAttentionList:params success:^(id json) {
        
    } fail:^{
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)edit:(id)sender
{
//    UIButton* itemButton = (UIButton*)sender;
//    itemButton.selected = !itemButton.selected;
//    self.isEdit = !self.isEdit;
//    [self calculateSelectdCount];
//    for (int i=0; i<shoppingInfos.count; i++)
//    {
//        NSArray *goodsList = ((CZJShoppingCartInfoForm*)shoppingInfos[i]).items;
//        for (int j = 0; j<goodsList.count-1; j++)
//        {
//            CZJShoppingGoodsInfoForm *model = goodsList[j];
//            if (model.off) {
//                model.isSelect=!self.isEdit;
//            }
//            else
//            {
//                model.isSelect=self.isEdit ? YES : NO;
//            }
//        }
//    }
//    [self pitchOn];
//    [self.myTableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark - LXDSegmentControlDelegate
- (void)segmentControl: (LXDSegmentControl *)segmentControl didSelectAtIndex: (NSUInteger)index
{
    _currentType = [NSString stringWithFormat:@"%ld",index + 1];
    [self getDataAttentionDataFromServer];
    DLog(@"%ld",index);
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
    
}

- (IBAction)selectAllAction:(id)sender
{
    
}
@end
