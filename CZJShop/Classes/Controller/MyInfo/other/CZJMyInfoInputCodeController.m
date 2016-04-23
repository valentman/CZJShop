//
//  CZJMyInfoInputCodeController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoInputCodeController.h"
#import "CZJBaseDataManager.h"

@interface CZJMyInfoInputCodeController ()
<
UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *inputCodeTextField;

- (IBAction)confirmAction:(id)sender;
@end

@implementation CZJMyInfoInputCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnBack.hidden = YES;
    
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];
    self.inputCodeTextField.leftView = paddingView;
    self.inputCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.inputCodeTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)confirmAction:(id)sender
{
    [self.view endEditing:YES];
    [CZJBaseDataInstance generalPost:@{@"type": @"1", @"content": self.inputCodeTextField.text} success:^(id json) {
        NSDictionary* dict = [CZJUtils DataFromJson:json];
    }  fail:^{
        
    } andServerAPI:kCZJServerAPIPGetScanCode];
}
@end
