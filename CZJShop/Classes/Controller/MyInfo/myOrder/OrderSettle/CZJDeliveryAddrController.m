//
//  CZJDeliveryAddrController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJDeliveryAddrController.h"
#import "CZJDeliveryAddrListCell.h"
#import "CZJAddDeliveryAddrController.h"
#import "CZJBaseDataManager.h"


@interface CZJDeliveryAddrController ()
<
UITableViewDataSource,
UITableViewDelegate,
CZJDeliveryAddrListCellDelegate
>
{
    NSMutableArray* _addrListAry;
    NSInteger _currentTouchIndexPath;
}
@property (weak, nonatomic) IBOutlet UITableView *addrListTableView;

@end

@implementation CZJDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    
    
    _addrListAry = [NSMutableArray array];
    self.addrListTableView.delegate = self;
    self.addrListTableView.dataSource = self;
    UINib* nib = [UINib nibWithNibName:@"CZJDeliveryAddrListCell" bundle:nil];
    [self.addrListTableView registerNib:nib forCellReuseIdentifier:@"CZJDeliveryAddrListCell"];
    self.addrListTableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getAddrListDataFromServer];
}


- (void)getAddrListDataFromServer
{
    [CZJBaseDataInstance loadAddrList:nil Success:^(id json){
        [self convertJsonDataToModel:json];
    } fail:^{
        
    }];
}

- (void)convertJsonDataToModel:(id)json
{
    [_addrListAry removeAllObjects];
    NSArray* tmpAry = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
    for (NSDictionary* dict in tmpAry)
    {
        CZJAddrForm* form  = [CZJAddrForm objectWithKeyValues:dict];
//        form.receiver = [dict valueForKey:@"receiver"];
//        form.province = [dict valueForKey:@"province"];
//        form.city = [dict valueForKey:@"city"];
//        form.county = [dict valueForKey:@"county"];
//        form.dftFlag = [[dict valueForKey:@"dftFlag"] boolValue];
//        form.mobile = [dict valueForKey:@"mobile"];
//        form.addr = [dict valueForKey:@"addr"];
//        form.addrId = [dict valueForKey:@"id"];
//        form.isSelected = NO;
//        if ([_currentAddrId isEqualToString:form.addrId])
//        {
//            form.isSelected = YES;
//        }
        [_addrListAry addObject:form];
    }
    [self.addrListTableView reloadData];
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
    return _addrListAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJAddrForm* form = (CZJAddrForm*)_addrListAry[indexPath.row];
    CZJDeliveryAddrListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrListCell" forIndexPath:indexPath];
    NSString* addrStr = [NSString stringWithFormat:@"%@ %@ %@ %@ ",form.province,form.city,form.county,form.addr];

    CGSize addrSize = [CZJUtils calculateStringSizeWithString:addrStr Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 100];
    cell.deliveryAddrLayoutWidth.constant = addrSize.width;
    cell.deliveryNameLabel.text = form.receiver;
    cell.deliveryPhoneNumLable.text = form.mobile;
    cell.deliveryAddrLabel.text = addrStr;
    cell.setDefaultBtn.selected = form.dftFlag;
    cell.chooseedBtn.selected = [_currentAddrId isEqualToString:form.addrId];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 137;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJAddrForm* form = (CZJAddrForm*)_addrListAry[indexPath.row];
    [self.delegate clickChooseAddr:form];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark- CZJDeliveryAddrListCellDelegate
- (void)clickEditAddrButton:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    _currentTouchIndexPath = indexPath.row;
    [self performSegueWithIdentifier:@"segueToAddDeliveryAddr" sender:sender];
}

- (void)clickDeleteAddrButton:(id)sender andIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* params = @{@"id" : ((CZJAddrForm*)_addrListAry[indexPath.row]).addrId};
    [CZJBaseDataInstance removeDeliveryAddr:params Success:^(id json){
        [_addrListAry removeObjectAtIndex:indexPath.row];
        [_addrListTableView reloadData];
    } fail:^{
        
    }];
}

- (void)clickSetDefault:(id)sender andIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* params = @{@"id" : ((CZJAddrForm*)_addrListAry[indexPath.row]).addrId};
    [CZJBaseDataInstance setDefaultAddr:params Success:^(id json){
        for (int i = 0; i < _addrListAry.count; i ++)
        {
            CZJAddrForm* form = _addrListAry[i];
            form.dftFlag = NO;
            if (i == indexPath.row)
            {
                form.dftFlag = YES;
                continue;
            }
        }
        [self.addrListTableView reloadData];
    } fail:^{
        
    }];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton* tmpBtn = (UIButton*)sender;
    if (0 == tmpBtn.tag)
    {
        CZJAddDeliveryAddrController* addControl =  segue.destinationViewController;
        addControl.addrForm = _addrListAry[_currentTouchIndexPath];
    }
}
@end
