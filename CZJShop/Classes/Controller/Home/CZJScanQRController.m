//
//  CZJScanQRController.m
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJScanQRController.h"

@interface CZJScanQRController ()
@property(nonatomic) BOOL dragDown;

- (IBAction)openTorch:(id)sender;
- (void)stopReading;
- (BOOL)startReading;
@end

@implementation CZJScanQRController

#pragma mark- Init
- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils hideSearchBarViewForTarget:self];
    [CZJUtils customizeNavigationBarForTarget:self];

    
    _captureSession = nil;
    _isReading = NO;
    _isLighting = NO;
    _dragDown = YES;
    [_operatorView setHidden:YES];
    [_indicator startAnimating];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark- 开关闪光灯
- (IBAction)openTorch:(id)sender {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (!_isLighting)
        {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
            _isLighting = YES;
            [_lightButton setTitle: @"关闭闪光灯" forState:UIControlStateNormal];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
            _isLighting = NO;
            [_lightButton setTitle: @"打开闪光灯" forState:UIControlStateNormal];
        }
    }
}

#pragma mark- 开始扫描

- (void)stopReading
{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
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
    //4.1讲输入流添加到会话
    [_captureSession addInput:input];
    //4.2讲媒体输出流添加到会话
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
    //10.1扫描框
    _boxView  = [[UIView alloc] initWithFrame:CGRectMake(_preView.bounds.size.width*0.2f, _preView.bounds.size.height*0.3f, _preView.bounds.size.width*0.6, _preView.bounds.size.height*0.6*PJ_SCREEN_ASPECTRATIO)];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 2.0f;
    [_operatorView addSubview:_boxView];
    //10.2扫描线
    _scanLayer = [[CALayer alloc]init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 2);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    [_boxView.layer addSublayer:_scanLayer];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    [timer fire];
    
    //11开始扫描
    [_captureSession startRunning];
    [_indicator stopAnimating];
    [_operatorView setHidden:NO];
    
    _hintLabel = [[UILabel alloc]init];
    _hintLabel.font = [UIFont systemFontOfSize:12];
    _hintLabel.text = @"对准二维码/条形码到框内即可扫描";
    _hintLabel.textColor = [UIColor whiteColor];
    [_operatorView addSubview:_hintLabel];
    [_hintLabel setFrame:CGRectMake(PJ_SCREEN_WIDTH*0.5 - 95, _boxView.frame.origin.y - 35, 190, 40)];
    return YES;
}

- (void)moveScanLayer:(NSTimer*)timer
{
    CGRect frame = _scanLayer.frame;
    if (_dragDown)
    {
        frame.origin.y += 1;
        _scanLayer.frame = frame;
        if (_boxView.frame.size.height <= _scanLayer.frame.origin.y)
        {
            _dragDown = NO;
        }
    }
    else
    {
        frame.origin.y -= 1;
        _scanLayer.frame = frame;
        if (0 >= _scanLayer.frame.origin.y)
        {
            _dragDown = YES;
        }
    }
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
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
        }
    }
}

@end
