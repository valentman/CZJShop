//
//  CZJRegisterController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJRegisterController.h"
#import "CZJLoginModelManager.h"
#import "LJWKeyboardHandlerHeaders.h"
#import "CZJLoginController.h"
#define kLoginColorRed RGB(255, 102, 102)

@interface CZJRegisterController ()
<
UITextFieldDelegate,
UIGestureRecognizerDelegate,
FDAlertViewDelegate
>
{
    BOOL isIdentityVerify;
}
@property (weak, nonatomic) IBOutlet UIButton *identityVerifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UIButton *resetPWDBtn;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumPrompt;
@property (weak, nonatomic) IBOutlet UILabel *codePrompt;
@property (weak, nonatomic) IBOutlet UILabel *pwdPrompt;

@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIView *pwdView;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UIView *protocolView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *daojishiLab;
@property (weak, nonatomic) IBOutlet UIButton *isPasswordTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeProtocolBtn;


- (IBAction)getCodeAction:(id)sender;
- (IBAction)confirmAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)exitAction:(id)sender;
- (IBAction)isSecurityPwdAction:(id)sender;

@end

@implementation CZJRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self registerLJWKeyboardHandler];
    [self.agreeProtocolBtn setImage:[UIImage imageNamed:@"login_icon_select_sel"] forState:UIControlStateSelected];
    [self.agreeProtocolBtn setImage:[UIImage imageNamed:@"login_icon_select"] forState:UIControlStateNormal];
    [self.agreeProtocolBtn setSelected:YES];
    isIdentityVerify = YES;
    [self.daojishiLab setHidden:YES];
    
    [self.isPasswordTypeBtn setImage:[UIImage imageNamed:@"login_btn_eye_on"] forState:UIControlStateSelected];
    [self.isPasswordTypeBtn setImage:[UIImage imageNamed:@"login_btn_eye_off"] forState:UIControlStateNormal];
    [self.isPasswordTypeBtn setSelected:NO];
    
    self.phoneNumTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.codeTextField.delegate = self;
    [self.phoneNumTextField setTag:1000];
    [self.pwdTextField setTag:1001];
    [self.codeTextField setTag:1002];
    
    self.identityVerifyBtn.backgroundColor = UIColorFromRGB(0xff9494);
    self.identityVerifyBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.stateButton setImage:[UIImage imageNamed:@"login_img_titlebase2"] forState:UIControlStateNormal];
    self.resetPWDBtn.backgroundColor = UIColorFromRGB(0xe0e0e0);
    self.resetPWDBtn.titleLabel.textColor = [UIColor lightGrayColor];
    
    [self.confirmBtn setEnabled:NO];
    self.confirmBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- Actions
- (IBAction)getCodeAction:(id)sender
{
    //输入内容校验（是不是手机号，以及有没有输入文字）
    if (!self.phoneNumTextField.text ||
        ![CZJUtils isPhoneNumber:self.phoneNumTextField.text] ||
        [self.phoneNumTextField.text isEqualToString:@""])
    {
        [self showAlert:@"请输入正确手机号码!"];
        return;
    }
    
    if (self.getCodeBtn.enabled)
    {
        CZJGeneralBlock successblock = ^(){
            [self.getCodeBtn setEnabled:NO];
            [self.getCodeBtn setHidden:YES];
            [self.daojishiLab setHidden:NO];
            
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

- (IBAction)confirmAction:(id)sender
{
    //验证手机有效性
    if (isIdentityVerify &&
        self.phoneNumTextField.text.length == 11 &&
        self.codeTextField.text.length > 0)
    {
        [self.confirmBtn setEnabled:NO];
        self.confirmBtn.backgroundColor = [UIColor lightGrayColor];
        CZJSuccessBlock successBlock = ^(id json){
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if ([[dict valueForKey:@"code"] integerValue] != 0)
            {
                [self showAlert:[dict valueForKey:@"msg"]];
                return;
            }
            
            //身份验证成功
            [self showAlert:@"身份验证成功，请设置密码"];
            isIdentityVerify = NO;
            
            //顶部身份验证和设置密码栏重置
            self.identityVerifyBtn.backgroundColor = UIColorFromRGB(0xe0e0e0);
            self.identityVerifyBtn.titleLabel.textColor = [UIColor lightGrayColor];
            [self.stateButton setImage:[UIImage imageNamed:@"login_img_titlebase"] forState:UIControlStateNormal];
            self.resetPWDBtn.backgroundColor = UIColorFromRGB(0xff9494);
            self.resetPWDBtn.titleLabel.textColor = [UIColor whiteColor];
            
            //密码栏显示，验证码栏和服务协议隐藏
            [self.codeView setHidden:YES];
            [self.pwdView setHidden:NO];
            [self.protocolView setHidden:YES];
            
            self.phoneNumTextField.enabled = NO;
            self.phoneNumTextField.textColor = [UIColor lightGrayColor];
        };
        CZJFailureBlock failure = ^{
            NSLog(@"login fail");
            self.confirmBtn.enabled = YES;
            [self.confirmBtn setBackgroundColor:kLoginColorRed];
        };
        [CZJLoginModelInstance loginWithAuthCode:self.codeTextField.text
                                     mobilePhone:self.phoneNumTextField.text
                                         success:successBlock
                                            fali:failure];
    }
    //重设密码中
    if (!isIdentityVerify &&
        self.codeTextField.text.length > 0)
    {
        [self.confirmBtn setEnabled:NO];
        CZJSuccessBlock successBlock = ^(id json){
            NSDictionary* dict = [CZJUtils DataFromJson:json];
            if ([[dict valueForKey:@"code"] integerValue] != 0)
            {
                [self showAlert:[dict valueForKey:@"msg"]];
            }
            [self.confirmBtn setEnabled:YES];
            self.confirmBtn.backgroundColor = kLoginColorRed;
        };
        CZJFailureBlock failure = ^{
            NSLog(@"login fail");
            [self.confirmBtn setEnabled:YES];
            self.confirmBtn.backgroundColor = kLoginColorRed;
        };
        [CZJLoginModelInstance setPassword:self.pwdTextField.text
                               mobliePhone:self.phoneNumTextField.text
                                   success:successBlock
                                      fali:failure];
    }
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)exitAction:(id)sender
{
    NSArray* views = [self.navigationController viewControllers];
    for (id view in views)
    {
        if ([view isKindOfClass:[CZJLoginController class]])
        {
            [view exitOutAction:nil];
        }
    }
}

- (IBAction)isSecurityPwdAction:(id)sender {
    BOOL flag = self.isPasswordTypeBtn.isSelected;
    [self.isPasswordTypeBtn setSelected:!flag];
    self.pwdTextField.secureTextEntry = flag;
}

- (void)showAlert:(NSString*)str{
    FDAlertView *alert = [[FDAlertView alloc] initWithTitle:@"提示"
                                                       icon:nil
                                                    message:[NSString stringWithFormat:@"%@ !",str]
                                                   delegate:self
                                               buttonTitles:@"确定",nil];
    [alert show];
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
        case 1000:
            [self.phoneNumPrompt setHidden:YES];
            break;
            
        case 1001:
            [self.pwdPrompt setHidden:YES];
            break;
            
        case 1002:
            [self.codePrompt setHidden:YES];
            break;
            
        default:
            break;
    }
    DLog();
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000:
            if (textField.text.length == 0) {
                [self.phoneNumPrompt setHidden:NO];
            }
            break;
            
        case 1001:
            if (textField.text.length == 0) {
                [self.pwdPrompt setHidden:NO];
            }
            if (textField.text.length > 0)
            {
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:kLoginColorRed];
            }
            break;
            
        case 1002:
            if (textField.text.length == 0) {
                [self.codePrompt setHidden:NO];
            }
            if (textField.text.length == 6 && self.phoneNumTextField.text.length == 11)
            {
                self.confirmBtn.enabled = YES;
                [self.confirmBtn setBackgroundColor:kLoginColorRed];
            }
            break;
            
        default:
            break;
    }
}

@end
