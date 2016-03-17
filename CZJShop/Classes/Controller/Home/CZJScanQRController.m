//
//  CZJScanQRController.m
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJScanQRController.h"
#import "CZJQRView.h"
#import "CZJWebViewController.h"
#import "CZJDetailViewController.h"
#import "CZJStoreDetailController.h"
#import "CZJCommitOrderController.h"
#import "CZJHomeViewController.h"

@implementation CZJSCanQRForm
@end

@interface CZJScanQRController ()
<
AVCaptureMetadataOutputObjectsDelegate,
UIAlertViewDelegate
>
{
    AVCaptureSession * _AVSession;
    CGSize transparentArea;
    BOOL isHomeview;
}
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UIView *operatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) UILabel* hintLabel;
@property (strong, nonatomic) UIView* boxView;
@property (strong, nonatomic) CZJQRView* qrView;
@property (strong, nonatomic) CALayer* scanLayer;
@property (strong, nonatomic) AVCaptureSession * AVSession;
@property (strong, nonatomic) AVCaptureSession* captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic) BOOL isLighting;
@property (nonatomic) BOOL dragDown;

- (void)openTorch:(id)sender;
- (void)stopReading:(id)sender;
- (BOOL)startReading;
@end

@implementation CZJScanQRController

#pragma mark- Init
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initScanData];
}

- (void)initScanData
{
    _captureSession = nil;
    _isReading = NO;
    _isLighting = NO;
    _dragDown = YES;
    [_operatorView setHidden:YES];
    [_indicator startAnimating];
    
    transparentArea = CGSizeMake(200, 200);
}

- (void)initViews
{
    [_operatorView addSubview:self.qrView];
    
    //导航栏初始
    [CZJUtils hideSearchBarViewForTarget:self];
    [self addCZJNaviBarView:CZJNaviBarViewTypeScan];
    self.naviBarView.mainTitleLabel.text = @"条形码/二维码";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //打开/关闭闪光灯按钮
    UIButton* btnTorch = [[ UIButton alloc ]initWithFrame:CGRectMake((PJ_SCREEN_WIDTH - 100)*0.5, PJ_SCREEN_HEIGHT - 150, 100, 100)];
    [btnTorch setImage:IMAGENAMED(@"scan_icon_light") forState:UIControlStateNormal];
    [btnTorch setImage:IMAGENAMED(@"scan_icon_light_sel") forState:UIControlStateSelected];
    [btnTorch addTarget:self action:@selector(openTorch:) forControlEvents:UIControlEventTouchUpInside];
    [btnTorch setSelected:NO];
    [_operatorView addSubview:btnTorch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startReading];
    [self initViews];
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSArray* views = self.navigationController.viewControllers;
    isHomeview = [views.lastObject isKindOfClass:[CZJHomeViewController class]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!isHomeview)
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(CZJQRView *)qrView {
    
    if (!_qrView) {
        
        CGRect screenRect = PJ_SCREEN_BOUNDS;
        _qrView = [[CZJQRView alloc] initWithFrame:screenRect];
        _qrView.transparentArea = CGSizeMake(_preView.bounds.size.width*0.7, _preView.bounds.size.height*0.7*PJ_SCREEN_ASPECTRATIO);
        
        _qrView.backgroundColor = [UIColor clearColor];
    }
    return _qrView;
}

#pragma mark- 开关闪光灯
- (void)openTorch:(UIButton*)sender {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (!_isLighting)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
            _isLighting = YES;
            [sender setSelected:YES];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
            _isLighting = NO;
            [sender setSelected:NO];
        }
    }
}


- (BOOL)startReading
{
    NSError* error;
    //1.初始化捕捉设备，类型为AVMediaTypeVideo
    AVCaptureDevice* captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用caputureDevice创建输入流
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput* captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
    
    //4.实例化捕捉回话
    _captureSession = [[AVCaptureSession alloc]init];
    //4.1将输入流添加到会话
    [_captureSession addInput:input];
    //4.2将媒体输出流添加到会话
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流到队列当中
    dispatch_queue_t _dispatchQueue;
    _dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:_dispatchQueue];
    //5.2设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_preView.layer.bounds]; //全屏
    
    //9.将图层添加到预览view的图层上
    [_preView.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);

    //11开始扫描
    [_captureSession startRunning];
    [_indicator stopAnimating];
    [_operatorView setHidden:NO];
    
    _hintLabel = [[UILabel alloc]init];
    _hintLabel.font = [UIFont systemFontOfSize:12];
    _hintLabel.text = @"对准二维码/条形码到框内即可扫描";
    _hintLabel.textColor = LIGHTGRAYCOLOR;
    [_operatorView addSubview:_hintLabel];
    [_hintLabel setFrame:CGRectMake(PJ_SCREEN_WIDTH*0.5 - 95, (PJ_SCREEN_HEIGHT  + _preView.bounds.size.height*0.7*PJ_SCREEN_ASPECTRATIO)*0.5 - 30, 190, 15)];
    return YES;
}



#pragma mark- AVCaptureMetadataOutputObjectsDelegate
#pragma mark 二维码信息读取成功返回后处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type]isEqualToString:AVMetadataObjectTypeQRCode])
        {
            [_captureSession stopRunning];
            NSDictionary* dict = [CZJUtils dictionaryFromJsonString:metadataObj.stringValue];
            CZJSCanQRForm* scanForm = [CZJSCanQRForm objectWithKeyValues:dict];
            [self performSelectorOnMainThread:@selector(stopReading:) withObject:scanForm waitUntilDone:NO];
            _isReading = NO;
        }
    }
}


#pragma mark- 开始扫描
- (void)stopReading:(id)sender
{
    
    [self dealWithQRScanData:sender];
}

- (void)dealWithQRScanData:(CZJSCanQRForm*)scanForm
{
    BOOL isOver = YES;
    if (scanForm.type)
    {
        switch ([scanForm.type integerValue]) {// 0超链接 1服务 2商品 3门店 4结算 5个人优惠码 6门店优惠码 7合作码
            case 0:// 0超链接
                //            Intent urlIntent = new Intent(mContext,
                //                                          AllInfoAtWebviewActivity.class);
                //            urlIntent.putExtra("type", 9);
                //            urlIntent.putExtra("url", bean.content);
                //            startActivity(urlIntent);
            {
                CZJWebViewController* webView = (CZJWebViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"webViewSBID"];
                webView.cur_url = scanForm.content;
                [self.navigationController pushViewController:webView animated:YES];
            }
                
                break;
                
            case 1:
            case 2:// 1服务 2商品
            {
                CZJDetailViewController* detailVC = (CZJDetailViewController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDGoodsDetailVC];
                detailVC.storeItemPid = scanForm.content;
                detailVC.detaiViewType = CZJDetailTypeGoods;
                detailVC.promotionType = CZJGoodsPromotionTypeGeneral;
                detailVC.promotionPrice = @"";
                
                [self.navigationController pushViewController:detailVC animated:YES];
            }
                break;
                
            case 3:// 3门店
            {
                CZJStoreDetailController* storeDetailVC = (CZJStoreDetailController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDStoreDetailVC];
                storeDetailVC.storeId = scanForm.content;
                [self.navigationController pushViewController:storeDetailVC animated:YES];
            }
                break;
                
            case 4://4结算
            {
                CZJCommitOrderController* settleOrder = (CZJCommitOrderController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:kCZJStoryBoardIDCommitSettle];
                settleOrder.settleParamsAry = (NSArray*)scanForm.content;
            }
                break;
                
            case 5:
                //            showProgressDialog("处理中");
                //            HandlerUtils.scanCode(bean.type, bean.content, codeHandler,
                //                                  mContext);
                break;
                
            case 6:
                //            showProgressDialog("处理中");
                //            HandlerUtils.scanCode(bean.type, bean.content, codeHandler,
                //                                  mContext);
                break;
                
            case 7:
                //            showProgressDialog("处理中");
                //            HandlerUtils.scanCode(bean.type, bean.content, codeHandler,
                //                                  mContext);
                break;
                
            default:
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"无效二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                isOver = NO;
            }
                
                break;
        }
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"无效二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        isOver = NO;
    }
    
    if (isOver)
    {
        _captureSession = nil;
        [_scanLayer removeFromSuperlayer];
        [_videoPreviewLayer removeFromSuperlayer];
        _indicator.hidden = YES;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_captureSession startRunning];
}
@end
