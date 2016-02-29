//
//  CZJAddMyEvalutionController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJAddMyEvalutionController.h"
#import "VPImageCropperViewController.h"
#import "CZJBaseDataManager.h"

@interface CZJAddMyEvalutionController ()
<
UITextViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
VPImageCropperDelegate
>
{
    NSMutableArray* picAry;
    NSString* message;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *picView;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picBtnTop;

- (IBAction)addEvaluateAction:(id)sender;
- (IBAction)addPicAction:(id)sender;

@end

@implementation CZJAddMyEvalutionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.delegate = self;
    picAry = [NSMutableArray array];
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"追加评价";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addEvaluateAction:(id)sender
{
    NSDictionary* params = @{@"id": self.currentEvaluation.evaluateID,
                             @"addMessage": message == nil ? @"系统默认好评" : message,
                             @"addImgs":picAry};
    DLog(@"%@",[params description]);
    [CZJBaseDataInstance generalPost:params success:^(id json) {
        
    } andServerAPI:kCZJServerAPIAddEvalution];
}

- (IBAction)addPicAction:(id)sender
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)refreshPic
{
    
    [self.picView removeAllSubViewsExceptView:self.picBtn];
    
    int divide = (iPhone5 || iPhone4) ? 3 : 4;
    for (int i = 0; i < picAry.count; i++)
    {
        NSString* imgUrl = picAry[i];
        CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:divide];
        CZJDeletableImageView* picImage = [[CZJDeletableImageView alloc]initWithFrame:imageFrame andImageName:imgUrl];
        [picImage.deleteButton addTarget:self action:@selector(picViewDeleteBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.picView addSubview:picImage];
    }
    CGRect picBtnFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:picAry.count divide:divide];
    self.picBtnLeading.constant = picBtnFrame.origin.x;
    self.picBtnTop.constant = picBtnFrame.origin.y;
}

- (void)picViewDeleteBtnHandler:(UIButton*)sender
{
    CZJDeletableImageView* picImage = (CZJDeletableImageView*)[sender superview];
    [picImage removeFromSuperview];
    [picAry removeObject:picImage.imgName];
    [self refreshPic];
}

#pragma mark- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([CZJUtils isCameraAvailable] &&
            [CZJUtils doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([CZJUtils isRearCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([CZJUtils isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        //获取从ImagePicker返回来的图像信息生成一个UIImage
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [CZJUtils imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    __weak typeof(self) weak = self;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        NSData *imageData = UIImageJPEGRepresentation(editedImage,0.5);
        
        [CZJBaseDataInstance generalUploadImage:editedImage withAPI:kCZJServerAPIUploadImg Success:^(id json) {
            NSDictionary* dict = [[CZJUtils DataFromJson:json]valueForKey:@"msg"];
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:imageData key:[dict valueForKey:@"key"] token:[dict valueForKey:@"token"]
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          [MBProgressHUD hideAllHUDsForView:weak.view animated:true];
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          [picAry addObject:[dict valueForKey:@"url"]];
                          [weak refreshPic];
                      } option:nil];
        } fail:nil];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    DLog();
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    DLog();
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    DLog(@"%@",textView.text);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSInteger indexSection = textView.tag;
    message = textView.text;
    DLog(@"%@",textView.text);
}


- (void)textViewDidChange:(UITextView *)textView
{
    DLog(@"%@",textView.text);
}
@end
