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



@interface CZJAddDeliveryAddrController ()
{
    
    NSMutableArray* _selectedAddAry;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *chooseAddrBtn;
@property (weak, nonatomic) IBOutlet UITextField *detailedAddrTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *chooseAddrLabel;

- (IBAction)locationAction:(id)sender;
- (IBAction)setDefaultAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)chooseLocationAction:(id)sender;
@end

@implementation CZJAddDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)locationAction:(id)sender {
    [GKHpickerAddressView shareInstancePickerAddressByctrl:self block:^(UIViewController *ctrl, NSString *addressName) {
            _selectedAddAry = [[addressName componentsSeparatedByString:@" "] mutableCopy];
            _chooseAddrLabel.text = addressName;
        }];
}

- (IBAction)setDefaultAction:(id)sender {
    _defaultBtn.selected = !_defaultBtn.selected;
}

- (IBAction)chooseLocationAction:(id)sender {
    [self locationAction:sender];
}

- (IBAction)saveAction:(id)sender {
    //还需验证数据的有效性和正确性
    NSMutableDictionary* addrDict = [@{@"receiver": self.nameTextField.text,
                                       @"province": _selectedAddAry[0],
                                       @"city": _selectedAddAry[1],
                                       @"county": _selectedAddAry[2],
                                       @"dftFlag": self.defaultBtn.selected ? @"true" : @"false",
                                       @"mobile" : self.phoneNumTextField.text,
                                       @"addr" : self.detailedAddrTextField.text
                                       } mutableCopy];


    if (!_addrForm) {
        NSDictionary* params = @{@"paramJson" : [CZJUtils JsonFromData:addrDict]};
        [CZJBaseDataInstance addDeliveryAddr:params Success:^{
            [self.navigationController popViewControllerAnimated:YES];
        } fail:^{
            
        }];
    }
    else
    {
        [addrDict setObject:_addrForm.addrId forKey:@"id"];
        NSDictionary* params = @{@"paramJson" : [CZJUtils JsonFromData:addrDict]};
        [CZJBaseDataInstance updateDeliveryAddr:params Success:^{
            [self.navigationController popViewControllerAnimated:YES];
        } fail:^{
            
        }];
    }
    
}
@end
