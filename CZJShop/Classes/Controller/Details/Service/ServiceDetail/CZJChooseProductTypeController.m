//
//  CZJChooseProductTypeController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/25/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJChooseProductTypeController.h"
#import "CZJBaseDataManager.h"

@interface CZJChooseProductTypeController ()
{
    NSMutableDictionary* _params;
    NSMutableArray* _items;
}
@property(nonatomic, strong)UITableView* tableView;
@end

@implementation CZJChooseProductTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    _params = [NSMutableDictionary dictionary];
    _items = [NSMutableArray array];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getSKUDataFromServer
{
    [_params removeAllObjects];
    [_params setObject:self.storeItemPid forKey:@"storeItemPid"];
    [_params setObject:self.counterKey forKey:@"counterKey"];
    CZJSuccessBlock successBlock = ^(id json)
    {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray* tmpItems = [[dict valueForKey:@"msg"] valueForKey:@"items"];
        for (NSDictionary* dicts in tmpItems)
        {
            CZJGoodsSKU* sku = [[CZJGoodsSKU alloc]initWithDictionary:dicts];
            [_items addObject:sku];
        }
        NSArray* labels = [[dict valueForKey:@"msg"] valueForKey:@"labels"];
        NSArray* skus = [[dict valueForKey:@"msg"] valueForKey:@"skus"];
        for (NSDictionary* dictsku in skus)
        {
            NSArray* twoskus = [dictsku valueForKey:@"twoSkus"];
        }
    };
    
    [CZJBaseDataInstance loadGoodsSKU:_params
                              Success:successBlock
                                 fail:nil];
    
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
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *shoppingCaridentis = @"CZJReceiveCouponsCell";
//    CZJReceiveCouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingCaridentis];
//    if (self.coupons.count > 0)
//    {
//        CZJShoppingCouponsForm* couponForm = (CZJShoppingCouponsForm*)self.coupons[indexPath.row];
//        NSString* priceStri = [NSString stringWithFormat:@"￥%@",couponForm.value];
//        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(40)];
//        cell.couponPriceLabelLayout.constant = priceSize.width + 5;
//        cell.couponPriceLabel.text = priceStri;
//        
//        NSString* storeNameStr = couponForm.storeName;
//        int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 10;
//        CGSize storeNameSize = [storeNameStr boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: BOLDSYSTEMFONT(15)} context:nil].size;
//        cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
//        cell.storeNameLabelLayoutWidth.constant = width;
//        cell.storeNameLabel.text = storeNameStr;
//        cell.receiveTimeLabel.text = couponForm.validEndTime;
//        cell.useableLimitLabel.text = couponForm.name;
//        
//        [cell setCellIsTaken:couponForm.taked andServiceType:![couponForm.validServiceId isEqualToString:@"0"]];
//        
//        
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return nil;
}

@end
