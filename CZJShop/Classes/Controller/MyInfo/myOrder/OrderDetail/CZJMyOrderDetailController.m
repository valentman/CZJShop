//
//  CZJMyOrderDetailController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyOrderDetailController.h"
#import "CZJBaseDataManager.h"
#import "CZJOrderForm.h"
#import "CZJOrderDetailCell.h"
#import "CZJDeliveryAddrCell.h"


@interface CZJMyOrderDetailController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    CZJOrderDetailForm* orderDetailForm;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeight;

@property (weak, nonatomic) IBOutlet UIView *buildProgressView;
@property (weak, nonatomic) IBOutlet UIView *noReceiveView;
@property (weak, nonatomic) IBOutlet UIView *cancelOrderView;
@property (weak, nonatomic) IBOutlet UIView *carCheckView;
@property (weak, nonatomic) IBOutlet UIView *goEvaluateView;
@property (weak, nonatomic) IBOutlet UIView *returnedDetailView;
@end

@implementation CZJMyOrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getOrderDetailFromServer];
}

- (void)initViews
{
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.separatorViewHeight.constant = 0.5;
    
    NSArray* nibArys = @[@"CZJOrderDetailCell",
                         @"CZJDeliveryAddrCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"订单详情";
}

- (void)getOrderDetailFromServer
{
    NSDictionary* params = @{@"orderNo":self.orderNo};
    [CZJBaseDataInstance getOrderDetail:params Success:^(id json) {
        NSDictionary* dict = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        orderDetailForm = [CZJOrderDetailForm objectWithKeyValues:dict];
        [self.myTableView reloadData];
        
        if (!orderDetailForm.paidFlag)
        {
            //区分是服务和商品：type==0为商品，type==1为服务
            if (0 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue])
                {
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                }
                else if (2 == [orderDetailForm.status integerValue])
                {
                }
                else if (3 == [orderDetailForm.status integerValue])
                {
                }
                else if (4 == [orderDetailForm.status integerValue])
                {
                }
            }
            else if (1 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue])
                {
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                }
                else if (2 == [orderDetailForm.status integerValue])
                {
                }
                else if (3 == [orderDetailForm.status integerValue])
                {
                }
                else if (4 == [orderDetailForm.status integerValue])
                {
                }
            }
        }
        else
        {
            if (0 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue])
                {
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                }
                else if (2 == [orderDetailForm.status integerValue])
                {
                }
                else if (3 == [orderDetailForm.status integerValue])
                {
                }
                else if (4 == [orderDetailForm.status integerValue])
                {
                }
            }
            else if (1 == [orderDetailForm.type integerValue])
            {
                if (0 == [orderDetailForm.status integerValue])
                {
                }
                else if (1 == [orderDetailForm.status integerValue])
                {
                }
                else if (2 == [orderDetailForm.status integerValue])
                {
                }
                else if (3 == [orderDetailForm.status integerValue])
                {
                }
                else if (4 == [orderDetailForm.status integerValue])
                {
                }
            }
        }

        
    } fail:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1 + (orderDetailForm.receiver.receiver == nil ? 0 : 1);
    }
    if (1 == section)
    {
        return  4 + orderDetailForm.items.count;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderDetailCell" forIndexPath:indexPath];
            cell.orderNoLabel.text = orderDetailForm.orderNo;
            cell.orderTimeLabel.text = orderDetailForm.createTime;
            
            
            
            return cell;
        }
        else if (1 == indexPath.row)
        {
            CZJDeliveryAddrCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrCell" forIndexPath:indexPath];
            cell.deliveryNameLabel.text = orderDetailForm.receiver.receiver;
            cell.deliveryAddrLabel.text = orderDetailForm.receiver.addr;
            cell.contactNumLabel.text = orderDetailForm.receiver.mobile;
            cell.defaultLabel.hidden = YES;
            cell.deliveryAddrLayoutLeading.constant = 41;
            cell.commitNextArrowImg.hidden = YES;
            return cell;
        }
    }
    
    return nil;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 175;
        }
        if (1 == indexPath.row)
        {

                return 85;
        }
    }
    if (1 == indexPath.section)
    {
        NSInteger itemCount = orderDetailForm.items.count;
        NSInteger giftCount = 0;
        
        if (0 == indexPath.row)
        {
            return 44;
        }
        else if (indexPath.row > 0 &&
                 indexPath.row <= itemCount)
        {
            return 108;

        }
        else if (indexPath.row > itemCount &&
                 indexPath.row <= itemCount + 2)
        {
            return 44;
        }
        else if (indexPath.row > itemCount + 2 &&
                 indexPath.row <= itemCount + 2 + giftCount)
        {
            return 30;
        }
        else if (indexPath.row > itemCount + 2 + giftCount &&
                 indexPath.row <= itemCount + 2 + giftCount + 1)
        {
            CGSize size = [CZJUtils calculateStringSizeWithString:orderDetailForm.note Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 30];
                return  60 + size.height;
        }
        else
        {
            return 44;
        }
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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
