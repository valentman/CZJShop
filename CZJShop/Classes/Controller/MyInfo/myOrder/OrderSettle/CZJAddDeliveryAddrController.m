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
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *chooseAddrBtn;
@property (weak, nonatomic) IBOutlet UITextField *detailedAddrTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) __block IBOutlet UILabel *chooseAddrLabel;

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
    _defaultBtn.selected = YES;
    
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
}

- (void)initMyViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"添加收货地址";
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
             }];
        }
    }
    else if (IS_IOS7)
    {
        if ([[ZXLocationManager sharedZXLocationManager] isLocationEnable]) {
            [self startSpin];
            [[ZXLocationManager sharedZXLocationManager] getAddress:^(NSString *addressString)
             {
                 [self stopSpin];
                 NSString* province = [CCLocationManager shareLocation].province;
                 NSString* city = [CCLocationManager shareLocation].city;
                 NSString* subCity = [CCLocationManager shareLocation].subCity;
                 _selectedAddAry[0] = province;
                 _selectedAddAry[1] = city;
                 _selectedAddAry[2] = subCity;
                 _chooseAddrLabel.text = [NSString stringWithFormat:@"%@ %@ %@",province,city,subCity];
                 [self stopSpin];
             }];
        }
    }
}

    
- (IBAction)setDefaultAction:(id)sender {
    _defaultBtn.selected = !_defaultBtn.selected;
}

- (IBAction)chooseLocationAction:(id)sender {
    [GKHpickerAddressView shareInstancePickerAddressByctrl:self block:^(UIViewController *ctrl, NSString *addressName) {
        _selectedAddAry = [[addressName componentsSeparatedByString:@" "] mutableCopy];
        _chooseAddrLabel.text = addressName;
    }];
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



@end
