//
//  CZJLoginController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJLoginController.h"
#import "CZJLoginModelManager.h"
#import "LJWKeyboardHandlerHeaders.h"
#import "ServiceProtocol.h"
#import "CZJBaseDataManager.h"
#import "CZJRegisterController.h"

#define kLoginColorRed RGB(255, 102, 102)
#define kPhoneNum 1000
#define kPwdNum 1001
#define kCodeNum 1002


@interface CZJLoginController ()
<
UITextFieldDelegate,
FDAlertViewDelegate
>
{
    BOOL isLoginWithCode;
    CGRect loginViewOriginRect;
}
@property (weak, nonatomic) IBOutlet UIButton *loginWithCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginWithPWDBtn;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *registAccountBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeProtocolBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumPrompt;
@property (weak, nonatomic) IBOutlet UILabel *pwdPrompt;
@property (weak, nonatomic) IBOutlet UILabel *codePrompt;
@property (weak, nonatomic) IBOutlet UIView *pwdView;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UIView *loginBtnView;
@property (weak, nonatomic) IBOutlet UIView *protocolView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UILabel *daojishiLab;
@property (weak, nonatomic) IBOutlet UIButton *isPasswordTypeBtn;


- (IBAction)loginWithCodeAction:(id)sender;
- (IBAction)loginWithPWDAction:(id)sender;
- (IBAction)getCodeAction:(id)sender;
- (IBAction)confirmLoginAction:(id)sender;
- (IBAction)isSecurityPwd:(id)sender;
- (IBAction)agreeProtocolAction:(id)sender;

@end

@implementation CZJLoginController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNaviBar];
    [self initViewButtons];
}

- (void)initNaviBar
{
    id navigationBarAppearance = self.navigationController.navigationBar;
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"nav_bargound"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.navigationBar.shadowImage =[UIImage imageNamed:@"nav_bargound"];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)initViewButtons
{
    //注册键盘
    [self registerLJWKeyboardHandler];
    self.phoneNumTextField.assistantHeight = 50;
    self.pwdTextField.assistantHeight = 50;
    self.codeTextField.assistantHeight = 50;
    
    [self.agreeProtocolBtn setImage:[UIImage imageNamed:@"login_icon_select_sel"] forState:UIControlStateSelected];
    [self.agreeProtocolBtn setImage:[UIImage imageNamed:@"login_icon_select"] forState:UIControlStateNormal];
    
    [self.isPasswordTypeBtn setImage:[UIImage imageNamed:@"login_btn_eye_on"] forState:UIControlStateSelected];
    [self.isPasswordTypeBtn setImage:[UIImage imageNamed:@"login_btn_eye_off"] forState:UIControlStateNormal];
    
    [self.agreeProtocolBtn setSelected:YES];
    [self.isPasswordTypeBtn setSelected:NO];
    
    
    [self.daojishiLab setHidden:YES];
    self.pwdTextField.secureTextEntry = YES;
    loginViewOriginRect = self.loginBtnView.frame;
    [self loginWithCodeAction:nil];
    
    self.phoneNumTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.codeTextField.delegate = self;
    [self.phoneNumTextField setTag:kPhoneNum];
    [self.pwdTextField setTag:kPwdNum];
    [self.codeTextField setTag:kCodeNum];
    
    self.confirmBtn.enabled = NO;
    self.confirmBtn.backgroundColor = [UIColor lightGrayColor];
    
    loginViewOriginRect = self.loginBtnView.frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Actions
- (IBAction)exitOutAction:(id)sender
{
//    [self.delegate didCancel:self];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginWithCodeAction:(id)sender
{
    isLoginWithCode = YES;
    //验证码登录时，获取验证码按钮显示，密码栏隐藏
    [self.codeView setHidden:NO];
    [self.pwdView setHidden:YES];
    [self.registAccountBtn setHidden:YES];
    [self.protocolView setHidden:NO];
    
    //按钮文字大小颜色随变
    self.loginWithCodeBtn.titleLabel.textColor = [UIColor blackColor];
    self.loginWithCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.loginWithPWDBtn.titleLabel.textColor = [UIColor grayColor];
    self.loginWithPWDBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    
    if (self.codeTextField.text.length == 0) {
        [self.codePrompt setHidden:NO];
    }
    else if (self.codeTextField.text.length > 0 && self.codeTextField.text.length < 6)
    {
        [self.codePrompt setHidden:YES];
        self.confirmBtn.enabled = NO;
        [self.confirmBtn setBackgroundColor:GRAYCOLOR];
        [self.codeTextField becomeFirstResponder];
    }
    else if (self.codeTextField.text.length == 6 && self.phoneNumTextField.text.length == 11)
    {
        [self.codePrompt setHidden:YES];
        self.confirmBtn.enabled = YES;
        [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
    }
}

- (IBAction)loginWithPWDAction:(id)sender
{
    isLoginWithCode = NO;
    //验证码登录时，获取验证码按钮隐藏，密码栏显示
    [self.codeView setHidden:YES];
    [self.pwdView setHidden:NO];
    [self.registAccountBtn setHidden:NO];
    [self.protocolView setHidden:YES];
    
    //按钮文字大小颜色随变
    self.loginWithCodeBtn.titleLabel.textColor = [UIColor grayColor];
    self.loginWithCodeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.loginWithPWDBtn.titleLabel.textColor = [UIColor blackColor];
    self.loginWithPWDBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    if (![CZJUtils isBlankString:self.phoneNumTextField.text])
    {
        [self.pwdTextField becomeFirstResponder];
    }
    if (self.pwdTextField.text.length == 0) {
        [self.pwdPrompt setHidden:NO];
        self.confirmBtn.enabled = NO;
        [self.confirmBtn setBackgroundColor:GRAYCOLOR];
    }
    if (self.pwdTextField.text.length > 0 && self.phoneNumTextField.text.length == 11)
    {
        [self.pwdPrompt setHidden:YES];
        self.confirmBtn.enabled = YES;
        [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
    }
}

- (IBAction)getCodeAction:(id)sender
{
    //输入内容校验（是不是手机号，以及有没有输入文字）
    if (!self.phoneNumTextField.text ||
        ![CZJUtils isPhoneNumber:self.phoneNumTextField.text] ||
        [self.phoneNumTextField.text isEqualToString:@""])
    {
        [CZJUtils tipWithText:@"请输入正确手机号码!" onView:self.view];
        return;
    }
    
    if (self.getCodeBtn.enabled)
    {
        CZJGeneralBlock successblock = ^(){
            [self.getCodeBtn setEnabled:NO];
            [self.getCodeBtn setHidden:YES];
            [self.daojishiLab setHidden:NO];
            [self.codeTextField becomeFirstResponder];
            
            __block int timeout=119; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(timer);
                    timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [self.getCodeBtn setEnabled:YES];
                        [self.getCodeBtn setHidden:NO];
                        [self.daojishiLab setHidden:YES];
                        [self.confirmBtn setEnabled:NO];
                        self.confirmBtn.backgroundColor = [UIColor lightGrayColor];
                        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                    });
                }else{
                    int seconds = timeout % 120;
                    NSString *strTime = [NSString stringWithFormat:@"重新发送(%d)", seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [self.getCodeBtn setEnabled:NO];
                        [self.getCodeBtn setHidden:YES];
                        [self.daojishiLab setHidden:NO];
                        [self.daojishiLab setText:strTime];
                    });
                    timeout--;
                }
            });
            dispatch_resume(timer);
        };
        
        [CZJLoginModelInstance getAuthCodeWithIphone:self.phoneNumTextField.text
                                             success:successblock
                                                fail:^(){}];
    }

}

- (IBAction)confirmLoginAction:(id)sender
{
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    CZJSuccessBlock successBlock = ^(id json){
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        if ([[dict valueForKey:@"code"] integerValue] != 0)
        {
            [CZJUtils tipWithText:[dict valueForKey:@"msg"] onView:weakSelf.view];
        }
        [weakSelf.confirmBtn setEnabled:YES];
        [weakSelf.confirmBtn setBackgroundColor:kLoginColorRed];
        
        //先处理登录成功数据
        [CZJLoginModelInstance loginSuccess:json success:^{
            //再发送购物车数量请求
            [CZJBaseDataInstance loadShoppingCartCount:nil Success:^(id json){
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                [CZJUtils tipWithText:@"登录成功" andView:nil];
                [weakSelf exitOutAction:nil];
            } fail:^{
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            }];
        } fail:^{
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        }];
    };
    CZJSuccessBlock failure = ^(id json){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        [CZJUtils tipWithText:[dict valueForKey:@"msg"] onView:weakSelf.view];
        [weakSelf.confirmBtn setEnabled:YES];
        [weakSelf.confirmBtn setBackgroundColor:kLoginColorRed];
    };
    //验证码登录
    if (isLoginWithCode &&
        self.phoneNumTextField.text.length == 11 &&
        self.codeTextField.text.length > 0)
    {
        [self.confirmBtn setEnabled:NO];
        [self.confirmBtn setBackgroundColor:[UIColor lightGrayColor]];
        [CZJLoginModelInstance loginWithAuthCode:self.codeTextField.text
                                     mobilePhone:self.phoneNumTextField.text
                                         success:successBlock
                                            fali:failure];
    }
    //密码登录
    if (!isLoginWithCode &&
        self.phoneNumTextField.text.length == 11 &&
        self.pwdTextField.text.length > 0)
    {
        [self.confirmBtn setEnabled:NO];
        [self.confirmBtn setBackgroundColor:[UIColor lightGrayColor]];
        
        [CZJLoginModelInstance loginWithPassword:self.pwdTextField.text
                                     mobilePhone:self.phoneNumTextField.text
                                         success:successBlock
                                            fali:failure];
    }
}

- (IBAction)isSecurityPwd:(id)sender {
    BOOL flag = self.isPasswordTypeBtn.isSelected;
    [self.isPasswordTypeBtn setSelected:!flag];
    self.pwdTextField.secureTextEntry = flag;
}

- (IBAction)agreeProtocolAction:(id)sender {
    BOOL flag = self.agreeProtocolBtn.isSelected;
    [self.agreeProtocolBtn setSelected:!flag];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"forgetToRegister"] ||
        [segue.identifier isEqualToString:@"createToRegister"])
    {
        CZJRegisterController* registerVC = segue.destinationViewController;
        registerVC.phoneNum = _phoneNumTextField.text;
    }
}


- (void)showAlert:(NSString*)str{
    [CZJUtils tipWithText:str onView:self.view];
}

- (void)alertView:(FDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld", (long)buttonIndex);
}

- (LJWKeyboardHandler *)registerLJWKeyboardHandler
{
    self.ljwKeyboardHandler = [[LJWKeyboardHandler alloc] init];
    
    return self.ljwKeyboardHandler;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kPhoneNum:
            [self.phoneNumPrompt setHidden:YES];
            break;
            
        case kPwdNum:
            [self.pwdPrompt setHidden:YES];
            break;
            
        case kCodeNum:
            [self.codePrompt setHidden:YES];
            break;
            
        default:
            break;
    }
    DLog();
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //-shouldChangeCharactersInRange gets called before text field actually changes its text, that's why you're getting old text value. To get the text after update use:
    NSString * new_text_str = [textField.text stringByReplacingCharactersInRange:range withString:string];//变化后的字符串
    switch (textField.tag) {
        case kPhoneNum:
            if (new_text_str.length == 0) {
                [self.phoneNumPrompt setHidden:NO];
            }
            if (new_text_str.length > 0)
            {
                [self.phoneNumPrompt setHidden:YES];
            }
            break;
            
        case kPwdNum:
            if (new_text_str.length == 0) {
                [self.pwdPrompt setHidden:NO];
                self.confirmBtn.enabled = NO;
                [self.confirmBtn setBackgroundColor:GRAYCOLOR];
            }
            if (new_text_str.length > 0 && self.phoneNumTextField.text.length == 11)
            {
                [self.pwdPrompt setHidden:YES];
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
            }
            break;
            
        case kCodeNum:
            if (new_text_str.length == 0) {
                [self.codePrompt setHidden:NO];
            }
            else if (new_text_str.length > 0 && new_text_str.length < 6)
            {
                [self.codePrompt setHidden:YES];
                self.confirmBtn.enabled = NO;
                [self.confirmBtn setBackgroundColor:GRAYCOLOR];
            }
            else if (new_text_str.length == 6 && self.phoneNumTextField.text.length == 11)
            {
                [self.codePrompt setHidden:YES];
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
            }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kPhoneNum:
            if (textField.text.length == 0) {
                [self.phoneNumPrompt setHidden:NO];
            }
            break;
            
        case kPwdNum:
            if (textField.text.length == 0) {
                [self.pwdPrompt setHidden:NO];
                self.confirmBtn.enabled = NO;
                [self.confirmBtn setBackgroundColor:GRAYCOLOR];
            }
            if (textField.text.length > 0 && self.phoneNumTextField.text.length == 11)
            {
                [self.pwdPrompt setHidden:YES];
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
            }
            break;
            
        case kCodeNum:
            if (textField.text.length == 0) {
                [self.codePrompt setHidden:NO];
            }
            else if (textField.text.length > 0 && textField.text.length < 6)
            {
                [self.codePrompt setHidden:YES];
                self.confirmBtn.enabled = NO;
                [self.confirmBtn setBackgroundColor:GRAYCOLOR];
            }
            else if (textField.text.length == 6 && self.phoneNumTextField.text.length == 11)
            {
                [self.codePrompt setHidden:YES];
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:CZJREDCOLOR];
            }
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
