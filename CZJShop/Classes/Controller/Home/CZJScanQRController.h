//
//  CZJScanQRController.h
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CZJScanQRController : UIViewController
{
    AVCaptureSession * _AVSession;
}
@property(nonatomic,retain)AVCaptureSession * AVSession;
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UIView *operatorView;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic)UILabel* hintLabel;
@property (strong, nonatomic) UIView* boxView;
@property (nonatomic)BOOL isReading;
@property (nonatomic)BOOL isLighting;
@property (strong, nonatomic) CALayer* scanLayer;
@property (strong, nonatomic)AVCaptureSession* captureSession;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer* videoPreviewLayer;
@end
