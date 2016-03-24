//
//  CZJReceiveCouponsController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJReceiveCouponsController.h"
#import "CZJReceiveCouponsCell.h"
#import "CZJShoppingCartForm.h"
#import "CZJBaseDataManager.h"

@interface CZJReceiveCouponsController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray* _coupons;
    NSDictionary* _params;
}

@property (nonatomic, strong)NSMutableArray* coupons;
@end

@implementation CZJReceiveCouponsController
@synthesize coupons = _coupons;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self getCouponsDataFromServer];
}

- (void)initView
{
    //弹出框顶部标题
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH/2 - 50, 15, 100, 21)];
    title.font=[UIFont systemFontOfSize:15];
    title.textColor=[UIColor blackColor];
    title.text = @"领取优惠券";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    //右上角叉叉退出按钮
    UIButton* _exitBt = [[UIButton alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 44, 5, 44, 44)];
    [_exitBt addTarget:self action:@selector(exitTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_exitBt setImage:IMAGENAMED(@"prodetail_icon_off") forState:UIControlStateNormal];
    [self.view addSubview:_exitBt];
    
    //底部分割线
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 50, PJ_SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [self.view addSubview:line];
    
    //添加TableView
    [self.view addSubview:self.tableView];
    UINib* nib = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
}

- (void)getCouponsDataFromServer
{
    CZJSuccessBlock successBlock = ^(id json){
        _coupons = [[CZJBaseDataInstance shoppingCartForm] shoppingCouponsList];
        [self.tableView reloadData];
    };
    _params = @{@"storeId" : _storeId};
    [CZJBaseDataInstance loadShoppingCouponsCart:_params
                                         Success:successBlock
                                            fail:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setCouponsAry:(NSMutableArray*)coupons
{
    self.coupons = [NSMutableArray array];
    self.coupons = coupons;
}


- (void)exitTouch:(id)sender
{
    if(self.basicBlock)self.basicBlock();
}

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock
{
    self.basicBlock = basicBlock;
}

- (UITableView *)tableView
{
    CGRect rect = [self.view bounds];
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50.5, PJ_SCREEN_WIDTH, rect.size.height - 50) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.userInteractionEnabled=YES;
        _tableView.dataSource = self;
        _tableView.scrollsToTop=YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;

    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coupons.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *shoppingCaridentis = @"CZJReceiveCouponsCell";
    CZJReceiveCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingCaridentis];
    cell.couponsViewLayoutWidth.constant = PJ_SCREEN_WIDTH - 40;
    if (self.coupons.count > 0)
    {
        CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)self.coupons[indexPath.row];
        NSString* priceStri = [NSString stringWithFormat:@"￥%@",couponForm.value];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(45)];
        cell.couponPriceLabelLayout.constant = priceSize.width + 5;
        cell.couponPriceLabel.text = priceStri;
        
        NSString* storeNameStr = couponForm.storeName;
        int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 10;
        CGSize storeNameSize = [storeNameStr boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: BOLDSYSTEMFONT(15)} context:nil].size;
        cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
        cell.storeNameLabelLayoutWidth.constant = width;
        cell.storeNameLabel.text = storeNameStr;
        cell.receiveTimeLabel.text = couponForm.validEndTime;
        cell.useableLimitLabel.text = couponForm.name;
        
        [cell setCellIsTaken:couponForm.taked andServiceType:![couponForm.validServiceId isEqualToString:@"0"]];
        
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block __weak CZJReceiveCouponsCell *cell  = [tableView cellForRowAtIndexPath:indexPath];

    CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)self.coupons[indexPath.row];
    NSDictionary* params = @{@"couponId": couponForm.couponId,
                             @"name": couponForm.name,
                             @"type": couponForm.type,
                             @"validServiceId": couponForm.validServiceId,
                             @"validStartTime": couponForm.validStartTime,
                             @"validEndTime": couponForm.validEndTime,
                             @"validMoney": couponForm.validMoney,
                             @"value": couponForm.value,
                             @"storeId": couponForm.storeId,
                             @"storeName": couponForm.storeName
                            };
    
    
    [CZJBaseDataInstance takeCoupons:params Success:^(id json){
        [cell setCellIsTaken:YES andServiceType:![couponForm.validServiceId isEqualToString:@"0"]];
    } fail:^{
        
    }];
}


@end
