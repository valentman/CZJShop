//
//  CZJMyInfoShareController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/12/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoShareController.h"
#import "ShareMessage.h"
#import "CommonUnit.h"
#import "CZJBaseDataManager.h"

@interface CZJMyInfoShareController ()
<MFMessageComposeViewControllerDelegate>
{
    NSString* _messageCode;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorLineHeight;
@property (weak, nonatomic) IBOutlet UIImageView *myQRCode;
@property (weak, nonatomic) IBOutlet UILabel *myCodeLabel;
@property (weak, nonatomic) IBOutlet UIView *shareView;

- (IBAction)msgShareAction:(id)sender;
- (IBAction)appShareAction:(id)sender;
@end

@implementation CZJMyInfoShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.btnBack.hidden = YES;
    [self initViews];
    [self generateQRCodeImage:_myShareCode andTarget:_myQRCode];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillLayoutSubviews
{
    _shareView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 60, PJ_SCREEN_WIDTH, 60);
}

- (void)viewDidLayoutSubviews
{
    _shareView.frame = CGRectMake(0, PJ_SCREEN_HEIGHT - 60, PJ_SCREEN_WIDTH, 60);
}

- (void)initViews
{
    self.separatorViewHeight.constant = 0.8;
    self.separatorLineHeight.constant = 0.8;
    
    _messageCode = [NSString stringWithFormat:@"%@%@",SHARE_CONTENT,SHARE_URL];
    
    
    //UIButton
    UIButton *leftBtn = [[ UIButton alloc ] initWithFrame : CGRectMake(- 20 , 0 , 88 , 44 )];
    [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [leftBtn setTitle:@"使用说明" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(introductions) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; //将leftItem设置为自定义按钮
    
    //UIBarButtonItem
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc]initWithCustomView: leftBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.myCodeLabel.text = _myShareCode;
}

- (void)generateQRCodeImage:(NSString*)ShareCode andTarget:(UIImageView*)QRCodeImage
{
    //二维码滤镜
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    [filter setDefaults];
    
    NSDictionary* myInfo = @{@"content" : ShareCode,@"isLogin" : @"1", @"type" : @"5"};
    
    //将字符串转换成NSData
    NSData *data=[CZJUtils JsonFormData:myInfo];
    
    //通过KVO设置滤镜inputmessage数据
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    BACK(^(){
        UIImage* tmpImag=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:180];
        
        MAIN(^(){
            QRCodeImage.image = tmpImag;
            CGRect qrFram = QRCodeImage.frame;
            DLog(@"qrframe: %f",qrFram.size.width);
            
            NSString* headImg = CZJBaseDataInstance.userInfoForm.headPic == nil ? @"icon-small" : CZJBaseDataInstance.userInfoForm.headPic;
            UIImageView* centerImage = [[UIImageView alloc]initWithImage:IMAGENAMED(headImg)];
            centerImage.layer.cornerRadius = 5;
            centerImage.clipsToBounds = YES;
            [centerImage setSize:CGSizeMake(40, 40)];
            [centerImage setPosition:CGPointMake(0.5*QRCodeImage.frame.size.width, 0.5* QRCodeImage.frame.size.height) atAnchorPoint:CGPointMake(0.5, 0.5)];
            [QRCodeImage addSubview:centerImage];
        });
    });
}


//改变二维码大小
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}


- (void)introductions
{
    CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
    webView.cur_url = [NSString stringWithFormat:@"%@%@",kCZJServerAddr,CODE_HINT];
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:NO completion:nil];//关键的一句不能为YES
    switch (result)
    {
        case MessageComposeResultCancelled:
            [CZJUtils tipWithText:@"发送取消" andView:self.view];
            break;
        case MessageComposeResultFailed:// send failed
            [[CommonUnit  shareCommonUnit] showAlertViewWithContent:@"发送成功"];
            break;
        case MessageComposeResultSent:
            [[CommonUnit  shareCommonUnit] showAlertViewWithContent:@"发送失败"];
            break;
        default:
            break;
    }
}
             

- (IBAction)msgShareAction:(id)sender
{//短信分享
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray array];
        controller.body = _messageCode;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"车之健"];//修改短信界面标题
    }else{
        [[CommonUnit  shareCommonUnit] showAlertViewWithContent:@"设备没有短信功能"];
    }
}

- (IBAction)appShareAction:(id)sender
{//社交分享
    [[ShareMessage shareMessage] showPanel:self.view Type:1 WithTitle:@"车之健" AndBody:_messageCode];
}
@end
