//
//  CZJMiaoShaListBaseController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMiaoShaListBaseController.h"
#import "CZJMiaoShaControlCell.h"
#import "CZJBaseDataManager.h"

@interface CZJMiaoShaListBaseController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* miaoShaAry;
    NSTimer* myTimer;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJMiaoShaListBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    //每分钟刷新秒杀页面一次
    myTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getMiaoShaDataFromServer) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [myTimer setFireDate:[NSDate distantPast]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [myTimer setFireDate:[NSDate distantFuture]];
}

- (void)initViews
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT - 30 - 50) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = WHITECOLOR;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJMiaoShaControlCell"];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}

- (void)getMiaoShaDataFromServer
{
    _params = @{@"skillId":_miaoShaTimes.skillId};
    [CZJUtils removeNoDataAlertViewFromTarget:self.view];
    [CZJBaseDataInstance generalPost:_params success:^(id json) {
        NSArray* tmpAry = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
        miaoShaAry = [CZJMiaoShaCellForm objectArrayWithKeyValuesArray:tmpAry];
        if (miaoShaAry.count == 0)
        {
            [CZJUtils showNoDataAlertViewOnTarget:self.view withPromptString:@"木有秒杀商品/(ToT)/~~"];
        }
        [self.myTableView reloadData];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIPGetSkillGoodsList];
}

- (void)removeNotificationFromMiaoSha
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCZJNotifikOrderListType object:nil];
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
    return miaoShaAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMiaoShaCellForm* miaoshaCellForm = miaoShaAry[indexPath.row];
    CZJMiaoShaControlCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMiaoShaControlCell" forIndexPath:indexPath];
    [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:miaoshaCellForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    cell.goodName.text = miaoshaCellForm.itemName;
    cell.goodNameLabelHeight.constant = [CZJUtils calculateTitleSizeWithString:miaoshaCellForm.itemName AndFontSize:17].height;
    NSString* currentPriceStr = [NSString stringWithFormat:@"￥%@",miaoshaCellForm.currentPrice];
    cell.currentPrice.text = currentPriceStr;
    cell.currentPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:currentPriceStr AndFontSize:17].width + 5;
    NSString* originPriceStr = [NSString stringWithFormat:@"￥%@",miaoshaCellForm.originalPrice];
    [cell.originPrice setAttributedText: [CZJUtils stringWithDeleteLine:originPriceStr]];
    cell.originPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:originPriceStr AndFontSize:12].width + 5;
    NSString* leftStr = [NSString stringWithFormat:@"仅限%@件",miaoshaCellForm.limitCount];
    cell.leftNum.text = leftStr;
    cell.leftNumWidth.constant = [CZJUtils calculateTitleSizeWithString:leftStr AndFontSize:12].width + 5;
    if ([miaoshaCellForm.limitPoint integerValue] < 1)
    {
        int rate = [miaoshaCellForm.limitPoint intValue]*100 /[miaoshaCellForm.limitCount intValue]*100;
        NSString* limitStr = [NSString stringWithFormat:@"已购%d%@",rate,@"%"];
        cell.alreadyBuyBtn.titleLabel.text = limitStr;
        [cell.alreadyBuyBtn setTitle:limitStr forState:UIControlStateNormal];
        float widt = cell.alreadyBuyBtn.frame.size.width * (1 - rate) * -1;
        cell.backgroundLabelTrailing.constant = widt;
        cell.goBuyBtn.userInteractionEnabled = NO;
    }
    else if (1 == [miaoshaCellForm.limitPoint integerValue])
    {
        cell.goingOnView.hidden = YES;
        cell.alreadyOverView.hidden = NO;
    }
    cell.separatorInset = HiddenCellSeparator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMiaoShaCellForm* cellForm = miaoShaAry[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(clickMiaoShaCell:)])
    {
        [self.delegate clickMiaoShaCell:cellForm];
    }
}


@end



@implementation CZJMiaoShaOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMiaoShaTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end



@implementation CZJMiaoShaThreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super getMiaoShaDataFromServer];
}

- (void)getMiaoShaDataFromServer
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end



@implementation CZJMiaoShaFourController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


@implementation CZJMiaoShaFiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super getMiaoShaDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end




