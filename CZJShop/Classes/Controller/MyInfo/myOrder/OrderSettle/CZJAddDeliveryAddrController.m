//
//  CZJAddDeliveryAddrController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAddDeliveryAddrController.h"
#import "GKHpickerAddressView.h"
#import "CZJBaseDataManager.h"
#import "CCLocationManager.h"
#import "ZXLocationManager.h"
#import "CZJDeliveryAddrController.h"
#import "LewPickerController.h"



@interface CZJAddDeliveryAddrController ()
<
LewPickerControllerDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate
>
{
    __block NSMutableArray* _selectedAddAry;
    BOOL _isAnimate;
    
    UIPickerView* _pickerView;
    __block UIView* _backgroundView;
    
    NSString* provinceStr;
    NSString* cityStr;
    NSString* subCityStr;
    
    NSInteger currentSelectPro;
    NSInteger currentSelectCity;
    NSInteger currentSelectTown;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *chooseAddrBtn;
@property (weak, nonatomic) IBOutlet UITextField *detailedAddrTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) __block IBOutlet UILabel *chooseAddrLabel;

@property (strong, nonatomic) NSDictionary *pickerDic;
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *townArray;
@property (strong, nonatomic) NSArray *selectedArray;

- (IBAction)locationAction:(id)sender;
- (IBAction)setDefaultAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)chooseLocationAction:(id)sender;
@end

@implementation CZJAddDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyDatas];
    [self initMyViews];
}


- (void)initMyDatas
{
    _selectedAddAry = [NSMutableArray array];
    _saveBtn.layer.cornerRadius = 5;
    [_defaultBtn setImage:[UIImage imageNamed:@"commit_btn_circle"] forState:UIControlStateNormal];
    [_defaultBtn setImage:[UIImage imageNamed:@"commit_btn_circle_sel"] forState:UIControlStateSelected];
    _defaultBtn.selected = NO;
    
    if (_addrForm)
    {
        _nameTextField.text = _addrForm.receiver;
        _selectedAddAry[0] = _addrForm.province;
        _selectedAddAry[1] = _addrForm.city;
        _selectedAddAry[2] = _addrForm.county;
        NSString* addrStr = [NSString stringWithFormat:@"%@ %@ %@",_addrForm.province, _addrForm.city,_addrForm.county];
        _chooseAddrLabel.text = addrStr;
        _defaultBtn.selected = _addrForm.dftFlag;
        _phoneNumTextField.text = _addrForm.mobile;
        _detailedAddrTextField.text = _addrForm.addr;
    }
    
    currentSelectPro = 0;
    currentSelectCity = 0;
    currentSelectTown = 0;
    
    [self getAddressPickerData];
}


- (void)getAddressPickerData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    self.pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.provinceArray = [self.pickerDic allKeys];
    self.selectedArray = [self.pickerDic objectForKey:[[self.pickerDic allKeys] objectAtIndex:0]];
    
    if (self.selectedArray.count > 0) {
        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
    }
    
    if (self.cityArray.count > 0) {
        self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
    }
}


- (void)initMyViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"编辑收货地址";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self locationAction:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _locationBtn.imageView.transform = CGAffineTransformRotate(_locationBtn.imageView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (_isAnimate) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!_isAnimate) {
        _isAnimate = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    _isAnimate = NO;
}


- (IBAction)locationAction:(id)sender
{
    if (IS_IOS8)
    {
        if ([[CCLocationManager shareLocation] isLocationEnable]) {
            [self startSpin];
            [[CCLocationManager shareLocation] getAddress:^(NSString *addressString)
             {
                 NSString* province = [CCLocationManager shareLocation].province;
                 NSString* city = [CCLocationManager shareLocation].city;
                 NSString* subCity = [CCLocationManager shareLocation].subCity;
                 _selectedAddAry[0] = province;
                 _selectedAddAry[1] = city;
                 _selectedAddAry[2] = subCity;
                 _chooseAddrLabel.text = [NSString stringWithFormat:@"%@ %@ %@",province,city,subCity];
                 [self stopSpin];
                 [self generateAddrToNum:_selectedAddAry];
             }];
        }
    }
    else if (IS_IOS7)
    {
        if ([[ZXLocationManager sharedZXLocationManager] isLocationEnable]) {
            [self startSpin];
            [[ZXLocationManager sharedZXLocationManager] getAddress:^(NSString *addressString)
             {
                 NSString* province = [CCLocationManager shareLocation].province;
                 NSString* city = [CCLocationManager shareLocation].city;
                 NSString* subCity = [CCLocationManager shareLocation].subCity;
                 _selectedAddAry[0] = province;
                 _selectedAddAry[1] = city;
                 _selectedAddAry[2] = subCity;
                 _chooseAddrLabel.text = [NSString stringWithFormat:@"%@ %@ %@",province,city,subCity];
                 [self stopSpin];
                 [self generateAddrToNum:_selectedAddAry];
             }];
        }
    }
}

- (void)generateAddrToNum:(NSArray*)selectAddAry
{
    NSString* provinceName = selectAddAry[0];
    NSString* cityName = selectAddAry[1];
    NSString* townName = selectAddAry[2];
    
    //省份索引号
    currentSelectPro = [self.provinceArray indexOfObject:provinceName];
    
    //根据省份名称获取城市字典数组，通过城市名称获取城市索引号
    self.selectedArray = [self.pickerDic objectForKey:provinceName];
    DLog(@"%@",[self.selectedArray.keyValues description]);
    
    if (self.selectedArray.count > 0) {
        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
        currentSelectCity = [self.cityArray indexOfObject:cityName];
    } else {
        self.cityArray = nil;
    }
    
    //根据城市名称获取地区数组，通过地区名称获取地区索引号
    if (self.cityArray.count > 0) {
        self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:currentSelectCity]];
        currentSelectTown = [self.townArray indexOfObject:townName];
    } else {
        self.townArray = nil;
    }
}

    
- (IBAction)setDefaultAction:(id)sender {
    _defaultBtn.selected = !_defaultBtn.selected;
}

- (IBAction)chooseLocationAction:(id)sender {
    [self.view endEditing:YES];
    _pickerView = [[UIPickerView alloc]init];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    LewPickerController *pickerController = [[LewPickerController alloc]initWithDelegate:self];
    pickerController.pickerView = _pickerView;
    pickerController.titleLabel.text = @"选择省市区";
    pickerController.titleLabel.font = SYSTEMFONT(14);
    
    [self.view addSubview:_backgroundView];
    [UIView animateWithDuration:0.35 animations:^{
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    }];
    
    [pickerController showInView:self.view];
    
    if (currentSelectPro > 0)
    {
        [self pickerView:_pickerView didSelectRow:currentSelectPro inComponent:0];
        [_pickerView selectRow:currentSelectPro inComponent:0 animated:YES];
    }
    if (currentSelectCity > 0)
    {
        [self pickerView:_pickerView didSelectRow:currentSelectCity inComponent:1];
        [_pickerView selectRow:currentSelectCity inComponent:1 animated:YES];
    }
    if (currentSelectTown > 0)
    {
        [self pickerView:_pickerView didSelectRow:currentSelectTown inComponent:2];
        [_pickerView selectRow:currentSelectTown inComponent:2 animated:YES];
    }
}


- (IBAction)saveAction:(id)sender {
    [self.view endEditing:YES];
    //还需验证数据的有效性和正确性
    if ([CZJUtils isBlankString:self.nameTextField.text])
    {
        [CZJUtils tipWithText:@"请填写收货人姓名" andView:self.view];
        return;
    }
    if ([CZJUtils isBlankString:self.phoneNumTextField.text])
    {
        [CZJUtils tipWithText:@"请填写收货人手机号码" andView:self.view];
        return;
    }
    else if (![CZJUtils isMobileNumber:self.phoneNumTextField.text])
    {
        [CZJUtils tipWithText:@"请填写正确的手机号码" andView:self.view];
        return;
    }
    
    if (_selectedAddAry.count == 0)
    {
        [CZJUtils tipWithText:@"请填写省市区地址" andView:self.view];
        return;
    }
    if ([CZJUtils isBlankString:self.detailedAddrTextField.text])
    {
        [CZJUtils tipWithText:@"请添加街道详细地址" andView:self.view];
        return;
    }
    
    NSMutableDictionary* addrDict = [@{@"receiver": self.nameTextField.text,
                                       @"province": _selectedAddAry[0],
                                       @"city": _selectedAddAry[1],
                                       @"county": _selectedAddAry[2],
                                       @"dftFlag": self.defaultBtn.selected ? @"true" : @"false",
                                       @"mobile" : self.phoneNumTextField.text,
                                       @"addr" : self.detailedAddrTextField.text
                                       } mutableCopy];


    __weak typeof(self) weakSelf = self;
    if (!_addrForm) {
        NSDictionary* params = @{@"paramJson" : [CZJUtils JsonFromData:addrDict]};
        [CZJBaseDataInstance addDeliveryAddr:params Success:^{
            [CZJUtils tipWithText:@"添加地址成功" andView:weakSelf.view ];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            CZJDeliveryAddrController* deliverAddr = (CZJDeliveryAddrController*)[CZJUtils getViewControllerInUINavigator:weakSelf.navigationController withClass:[CZJDeliveryAddrController class]];
            [deliverAddr getAddrListDataFromServer];
        } fail:^{
            
        }];
    }
    else
    {
        [addrDict setObject:_addrForm.addrId forKey:@"id"];
        NSDictionary* params = @{@"paramJson" : [CZJUtils JsonFromData:addrDict]};
        [CZJBaseDataInstance updateDeliveryAddr:params Success:^{
            [CZJUtils tipWithText:@"更新地址成功" andView:weakSelf.view ];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            CZJDeliveryAddrController* deliverAddr = (CZJDeliveryAddrController*)[CZJUtils getViewControllerInUINavigator:weakSelf.navigationController withClass:[CZJDeliveryAddrController class]];
            [deliverAddr getAddrListDataFromServer];
        } fail:^{
            
        }];
    }
    
}


#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    } else {
        return self.townArray.count;
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return  [self.provinceArray objectAtIndex:row];
    } else if (component == 1) {
        return [self.cityArray objectAtIndex:row];
    } else {
        return [self.townArray objectAtIndex:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedArray = [self.pickerDic objectForKey:[self.provinceArray objectAtIndex:row]];
        if (self.selectedArray.count > 0) {
            self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
        } else {
            self.cityArray = nil;
        }
        if (self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
        } else {
            self.townArray = nil;
        }
    }
    [pickerView selectedRowInComponent:1];
    [pickerView reloadComponent:1];
    [pickerView selectedRowInComponent:2];
    
    if (component == 1) {
        if (self.selectedArray.count > 0 && self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:row]];
        } else {
            self.townArray = nil;
        }
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    [pickerView reloadComponent:2];
}

#pragma mark - LewPickerControllerDelegate
- (BOOL)lewPickerControllerShouldOKButtonPressed:(LewPickerController *)pickerController{
    
    currentSelectPro = [_pickerView selectedRowInComponent:0];
    currentSelectCity = [_pickerView selectedRowInComponent:1];
    currentSelectTown = [_pickerView selectedRowInComponent:2];
    provinceStr = _provinceArray[currentSelectPro];
    cityStr = _cityArray[currentSelectCity];
    subCityStr = _townArray[currentSelectTown];
    NSString *numberPlate = [NSString stringWithFormat:@"%@ %@ %@",provinceStr,cityStr,subCityStr];
    _chooseAddrLabel.text = numberPlate;
    [self closeBackgroundView];
    return  YES;
}

- (void)lewPickerControllerDidOKButtonPressed:(LewPickerController *)pickerController{
    NSLog(@"OK");
    [self closeBackgroundView];
}

- (void)lewPickerControllerDidCancelButtonPressed:(LewPickerController *)pickerController{
    NSLog(@"cancel");
    [self closeBackgroundView];
}

- (void)closeBackgroundView
{
    [UIView animateWithDuration:0.35 animations:^{
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    } completion:^(BOOL finished) {
        _pickerView = nil;
        [_backgroundView removeFromSuperview];
    }];
}

@end
