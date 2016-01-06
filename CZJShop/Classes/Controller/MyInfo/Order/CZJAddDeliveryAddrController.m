//
//  CZJAddDeliveryAddrController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAddDeliveryAddrController.h"
#import "GKHpickerAddressView.h"

@interface CZJAddDeliveryAddrController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *chooseAddrBtn;
@property (weak, nonatomic) IBOutlet UITextField *detailedAddrTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)locationAction:(id)sender;
- (IBAction)setDefaultAction:(id)sender;
- (IBAction)saveAction:(id)sender;
@end

@implementation CZJAddDeliveryAddrController

- (void)viewDidLoad {
    [super viewDidLoad];
    _saveBtn.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)locationAction:(id)sender {
    [GKHpickerAddressView shareInstancePickerAddressByctrl:self block:^(UIViewController *ctrl, NSString *addressName) {
        [_chooseAddrBtn setTitle:addressName forState:UIControlStateNormal];
    }];
}

- (IBAction)setDefaultAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {
}
@end
