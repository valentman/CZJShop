//
//  LewPickerController.m
//  NetEaseLocalActivities
//
//  Created by pljhonglu on 16/2/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LewPickerController.h"
#import <Accelerate/Accelerate.h>

#define Height_Picker 150
#define Height_ToolBar 44

#define kToolBarHeight 44
#define kActionSheetHeight 480

@interface UIImage (Blur)
- (UIImage*)boxblurImageWithBlur:(CGFloat)blur;
@end

@interface LewPickerController ()
@property (nonatomic, strong)UIToolbar *toolbar;
@property(nonatomic, strong, readwrite) UILabel * titleLabel;
@end

@implementation LewPickerController

- (id)initWithDelegate:(id<LewPickerControllerDelegate>)delegate{
    CGFloat width = [[UIScreen mainScreen]bounds].size.width;
    CGFloat height = [[UIScreen mainScreen]bounds].size.height;
    CGRect frame=CGRectMake(0, height+Height_Picker+Height_ToolBar, width, Height_ToolBar+Height_Picker + 60);
    
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    self.backgroundColor = WHITECOLOR;
    _delegate = delegate;
    
    //顶部栏
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, kToolBarHeight)];
    self.titleLabel.frame = CGRectMake(0, 0, width/2, kToolBarHeight);
    UIBarButtonItem *bbtTitle = [[UIBarButtonItem alloc] initWithCustomView:self.titleLabel];
    UIBarButtonItem* bbtOK = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shop_icon_location"] style:UIBarButtonItemStylePlain target:self action:@selector(locationAction:)];
    bbtOK.width = 60.f;
    [bbtOK setTintColor:CZJREDCOLOR];
    
    UIBarButtonItem *bbtCancel = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    bbtCancel.width = 60.f;
    [bbtCancel setTintColor:CZJREDCOLOR];
    
    UIBarButtonItem *fixItemLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixItemRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _toolbar.items = @[bbtCancel, fixItemLeft, bbtTitle, fixItemRight, bbtOK];
    [self addSubview:_toolbar];
    
    //保存按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    btn.layer.cornerRadius = 5.0;
    btn.backgroundColor = CZJREDCOLOR;
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(50, Height_ToolBar+Height_Picker, PJ_SCREEN_WIDTH - 100, 50);
    [self addSubview:btn];
    
    return self;
}

-(CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [[UIScreen mainScreen] bounds].size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = 0.4/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

-(void)showInView:(UIView*)target{
    CGRect sf = self.frame;
    CGRect vf = target.frame;
    CGRect f  = CGRectMake(0, (vf.size.height-sf.size.height)*0.5, vf.size.width, sf.size.height);
    CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
    
    UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];
    overlay.backgroundColor = [UIColor blackColor];
    
    UIGraphicsBeginImageContext(target.bounds.size);
    [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * ss = [[UIImageView alloc] initWithImage:[image boxblurImageWithBlur:0.1]];
    ss.backgroundColor = RGBA(30, 30, 30, 0.5);
    [overlay addSubview:ss];
    [target addSubview:overlay];
    
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.frame = of;
    [overlay addSubview:dismissButton];
    
//    [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
//    [UIView animateWithDuration:0.4 animations:^{
//        ss.alpha = 0.5;
//    }];
    
    // Present view animated
    self.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
    [target addSubview:self];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 0.2;
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = f;
    }];
}

-(void)dismissWithAnimation {
    UIView * target = [self superview];
    UIView * modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
    [UIView animateWithDuration:0.4 animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
    }];
    
//    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
//    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
//    [UIView animateWithDuration:0.4 animations:^{
//        ss.alpha = 1;
//    }];
}

#pragma mark - setter/getter
- (void)setToolbarStyle:(UIBarStyle)barStyle{
    _toolbar.barStyle = barStyle;
}

- (void)setPickerView:(UIView *)pickerView{
    if (_pickerView) {
        [_pickerView removeFromSuperview];
        _pickerView = nil;
    }
    _pickerView = pickerView;
    CGRect rect = CGRectMake(0, kToolBarHeight, [UIScreen mainScreen].bounds.size.width, Height_Picker);
    _pickerView.frame = rect;
    [self addSubview:_pickerView];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines=1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor grayColor];
    }
    return _titleLabel;
}

#pragma mark - action
- (void)okAction:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(lewPickerControllerShouldOKButtonPressed:)]) {
        if (![_delegate lewPickerControllerShouldOKButtonPressed:self]) {
            return;
        }
    }
    
    [self dismissWithAnimation];
    
    if (_delegate && [_delegate respondsToSelector:@selector(lewPickerControllerDidOKButtonPressed:)]) {
        [_delegate lewPickerControllerDidOKButtonPressed:self];
    }
}

- (void)cancelAction:(id)sender{
    [self dismissWithAnimation];
    if (_delegate && [_delegate respondsToSelector:@selector(lewPickerControllerDidCancelButtonPressed:)]) {
        [_delegate lewPickerControllerDidCancelButtonPressed:self];
    }
}

- (void)locationAction:(id)sender
{
    
}
@end

#pragma mark -
@implementation UIImage (Blur)
- (UIImage*)boxblurImageWithBlur:(CGFloat)blur{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    //不做转换有时候会崩掉
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    CGImageRef img = destImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend)
    ?: vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *boxBluredImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return boxBluredImage;
}
@end
