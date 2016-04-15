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
    __block NSMutableArray* _addrListAry;
    __block NSInteger _currentTouchIndexPath;
}
@property (weak, nonatomic) IBOutlet UITableView *addrListTableView;

@end

@implementation CZJDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _addrListAry = [NSMutableArray array];
    self.addrListTableView.delegate = self;
    self.addrListTableView.dataSource = self;
    self.addrListTableView.backgroundColor = CLEARCOLOR;
    UINib* nib = [UINib nibWithNibName:@"CZJDeliveryAddrListCell" bundle:nil];
    [self.addrListTableView registerNib:nib forCellReuseIdentifier:@"CZJDeliveryAddrListCell"];
    self.addrListTableView.tableFooterView = [[UIView alloc] init];
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"收货地址";
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
        if (form.dftFlag)
        {//每次更新地址之后都将更新地址中得默认地址存到本地
            [CZJUtils writeDictionaryToDocumentsDirectory:[form.keyValues mutableCopy] withPlistName:kCZJPlistFileDefaultDeliveryAddr];
        }
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
    return _addrListAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJAddrForm* form = (CZJAddrForm*)_addrListAry[indexPath.section];
    CZJDeliveryAddrListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJDeliveryAddrListCell" forIndexPath:indexPath];
    NSString* addrStr = [NSString stringWithFormat:@"%@ %@ %@ %@ ",form.province,form.city,form.county,form.addr];

    CGSize addrSize = [CZJUtils calculateStringSizeWithString:addrStr Font:SYSTEMFONT(12) Width:PJ_SCREEN_WIDTH - 100];
    cell.deliveryAddrLayoutWidth.constant = addrSize.width;
    cell.deliveryNameLabel.text = form.receiver;
    cell.deliveryPhoneNumLable.text = form.mobile;
    cell.deliveryAddrLabel.text = addrStr;
    cell.setDefaultBtn.selected = form.dftFlag;
    cell.chooseedBtn.selected = [_currentAddrId isEqualToString:form.addrId];
    cell.layer.borderWidth = [_currentAddrId isEqualToString:form.addrId] ? 0.5 : 0;
    cell.layer.borderColor = CZJREDCOLOR.CGColor;
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.separatorInset = HiddenCellSeparator;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 137;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJAddrForm* form = (CZJAddrForm*)_addrListAry[indexPath.section];
    [self.delegate clickChooseAddr:form];
    [self.navigationController popViewControllerAnimated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

#pragma mark- CZJDeliveryAddrListCellDelegate
- (void)clickEditAddrButton:(id)sender andIndexPath:(NSIndexPath*)indexPath
{
    _currentTouchIndexPath = indexPath.section;
    [self performSegueWithIdentifier:@"segueToAddDeliveryAddr" sender:sender];
}

- (void)clickDeleteAddrButton:(id)sender andIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确定删除该地址？" andConfirmHandler:^{
        NSString* willDeleteAddrId = ((CZJAddrForm*)_addrListAry[indexPath.section]).addrId;
        NSDictionary* params = @{@"id" : willDeleteAddrId};
        
        NSDictionary* addrDict = [CZJUtils readDictionaryFromDocumentsDirectoryWithPlistName:kCZJPlistFileDefaultDeliveryAddr];
        __block isDefalutDeliveryAddr = NO;
        CZJAddrForm* defalutAddr = [CZJAddrForm objectWithKeyValues:addrDict];
        if ([defalutAddr.addrId isEqualToString:willDeleteAddrId])
        {//所删除地址是否为默认地址，如果为默认地址，则删除本地存储的默认地址文件
            isDefalutDeliveryAddr = YES;
        }
        
        [CZJBaseDataInstance removeDeliveryAddr:params Success:^(id json){
            [_addrListAry removeObjectAtIndex:indexPath.section];
            [_addrListTableView reloadData];
            if (isDefalutDeliveryAddr)
            {
                [FileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:kCZJPlistFileDefaultDeliveryAddr] error:nil];
            }
        } fail:^{
            
        }];
        [weak hideWindow];
    } andCancleHandler:nil];
}

- (void)clickSetDefault:(id)sender andIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* params = @{@"id" : ((CZJAddrForm*)_addrListAry[indexPath.section]).addrId};
    [CZJBaseDataInstance setDefaultAddr:params Success:^(id json){
        for (int i = 0; i < _addrListAry.count; i ++)
        {
            CZJAddrForm* form = _addrListAry[i];
            form.dftFlag = NO;
            if (i == indexPath.section)
            {
                form.dftFlag = YES;
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
