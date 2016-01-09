//
//  CZJChooseCouponController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJChooseCouponController.h"
#import "CZJBaseDataManager.h"
#import "CZJReceiveCouponsCell.h"
#import "CZJOrderCouponHeaderCell.h"

@interface CZJChooseCouponController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSArray* _storeAry;
    NSArray* _storeCoupons;
}
@property (weak, nonatomic) IBOutlet UITableView *chooseCouponTableView;
- (IBAction)confirmToUseAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end

@implementation CZJChooseCouponController
@synthesize storeIds = _storeIds;
- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    _storeAry = [NSArray array];
    _storeCoupons = [NSArray array];
    
    UINib* nib1 = [UINib nibWithNibName:@"CZJOrderCouponHeaderCell" bundle:nil];
    UINib* nib2 = [UINib nibWithNibName:@"CZJReceiveCouponsCell" bundle:nil];
    [self.chooseCouponTableView registerNib:nib1 forCellReuseIdentifier:@"CZJOrderCouponHeaderCell"];
    [self.chooseCouponTableView registerNib:nib2 forCellReuseIdentifier:@"CZJReceiveCouponsCell"];
    self.chooseCouponTableView.delegate = self;
    self.chooseCouponTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.chooseCouponTableView.tableFooterView = [[UIView alloc] init];
    
    [self getCouponsListFromServer];
}

- (void)getCouponsListFromServer
{
    NSDictionary* params = @{@"storeIds" : _storeIds};
    TICK;
    [CZJBaseDataInstance loadUseableCouponsList:params Success:^(id json) {
        TOCK;
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        
        _storeAry = [dict valueForKey:@"msg"];
        [_chooseCouponTableView reloadData];
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _storeAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)[_storeAry[section] valueForKey:@"coupons"]).count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _storeCoupons = [_storeAry[indexPath.section] valueForKey:@"coupons"];
    if (0 == indexPath.row)
    {
        CZJOrderCouponHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderCouponHeaderCell" forIndexPath:indexPath];
        NSString* storeName = [_storeAry[indexPath.section] valueForKey:@"storeName"];
        CGSize storeNameSize = [CZJUtils calculateStringSizeWithString:storeName Font:SYSTEMFONT(15) Width:PJ_SCREEN_WIDTH - 60];
        cell.storeNameLayoutWidth.constant = storeNameSize.width;
        cell.storeName.text = storeName;
        cell.couponNumLabel.text = [NSString stringWithFormat:@"%ld",_storeCoupons.count];
        cell.selfImg.highlighted = [[_storeAry[indexPath.section] valueForKey:@"selfFlag"] boolValue];
        return cell;
    }
    else
    {
        CZJReceiveCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJReceiveCouponsCell" forIndexPath:indexPath];
        NSDictionary* couponDict = _storeCoupons[indexPath.row - 1];
        NSString* priceStri = [NSString stringWithFormat:@"￥%@",[couponDict valueForKey:@"value"]];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStri WithFont:SYSTEMFONT(40)];
        cell.couponPriceLabelLayout.constant = priceSize.width + 5;
        cell.couponPriceLabel.text = priceStri;
        
        NSString* storeNameStr = [couponDict valueForKey:@"storeName"];
        int width = PJ_SCREEN_WIDTH - 40 - 80 - priceSize.width - 10;
        CGSize storeNameSize = [storeNameStr boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: BOLDSYSTEMFONT(15)} context:nil].size;
        cell.storeNameLabelLayoutheight.constant = storeNameSize.height;
        cell.storeNameLabelLayoutWidth.constant = width;
        cell.storeNameLabel.text = storeNameStr;
        cell.receiveTimeLabel.text = [couponDict valueForKey:@"validEndTime"];
        cell.useableLimitLabel.text = [couponDict valueForKey:@"name"];
        
//        [cell setCellIsTaken:couponForm.taked andServiceType:![[couponDict valueForKey:@"validServiceId"] isEqualToString:@"0"]];
        return cell;

    }
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        return 46;
    }
    else {
        return 120;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (IBAction)confirmToUseAction:(id)sender
{
    [self.delegate clickToConfirmUse];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
