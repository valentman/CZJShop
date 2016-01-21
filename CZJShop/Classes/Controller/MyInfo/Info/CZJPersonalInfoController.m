//
//  CZJPersonalInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/13/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJPersonalInfoController.h"
#import "UIImageView+WebCache.h"
#import "UserBaseForm.h"
#import "CZJBaseDataManager.h"
#import "VPImageCropperViewController.h"
#import "LJWKeyboardHandlerHeaders.h"

@interface CZJPersonalInfoController ()
<
UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
VPImageCropperDelegate
>
{
    UIImageView * headview;
    UITextField* nameTextField;
    UITextField* phoneNumTextField;
    BOOL isFromServer;
}
@end

@implementation CZJPersonalInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    self.tableView.tableFooterView = [[UIView alloc] init];
    headview = [[UIImageView alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 51-15, 5, 51, 51)];
    headview.layer.cornerRadius = 25.5;
    headview.clipsToBounds = YES;
    [headview setContentMode:UIViewContentModeScaleAspectFill];
    [headview setTag:255];
    isFromServer = YES;
    
    nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 200 - 15, 15, 200, 21)];
    nameTextField.textAlignment = NSTextAlignmentRight;
    nameTextField.font = SYSTEMFONT(14);
    nameTextField.textColor = [UIColor lightGrayColor];
    [nameTextField setTag:255];
    phoneNumTextField = [[UITextField alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 200 - 15, 15, 200, 21)];
    phoneNumTextField.textAlignment = NSTextAlignmentRight;
    [phoneNumTextField setTag:255];
    phoneNumTextField.font = SYSTEMFONT(14);
    phoneNumTextField.textColor = [UIColor lightGrayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    btn.layer.cornerRadius = 5.0;
    btn.backgroundColor = CZJREDCOLOR;
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(unLogin:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(50, PJ_SCREEN_HEIGHT - 300, PJ_SCREEN_WIDTH - 100, 50);
    [self.tableView addSubview:btn];
    
    
}

- (void)unLogin:(id)sender
{
    DLog(@"退出登录");
    CZJBaseDataInstance.userInfoForm = nil;
    [USER_DEFAULT setObject:[NSNumber numberWithBool:YES] forKey:kCZJIsUserHaveLogined];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshTableView];
}

- (void)refreshTableView
{
    UserBaseForm* userinfo = CZJBaseDataInstance.userInfoForm;
    for (int i = 0; i < 4; i++)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (0 == i)
        {
            if (!VIEWWITHTAG(cell, 255))
            {
                [cell addSubview:headview];
            }
            if (isFromServer) {
                [headview sd_setImageWithURL:[NSURL URLWithString:userinfo.chezhuHeadImg] placeholderImage:nil];
            }
            
        }
        if (1 == i)
        {
            if (!VIEWWITHTAG(cell, 255))
            {
                [cell addSubview:nameTextField];
            }
            nameTextField.text = userinfo.chezhuName;
        }
        if (2 == i)
        {
            if (!VIEWWITHTAG(cell, 255))
            {
                [cell addSubview:phoneNumTextField];
            }
            phoneNumTextField.text = userinfo.mobile;
        }
        if (3 == i)
        {
            cell.detailTextLabel.text = [USER_DEFAULT objectForKey:kUSerDefaultSexual];
        }

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section)
    {
        return 4;
    }
    else
    {
        return 2;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
     DLog(@"section:%ld, row:%ld, name:%@, detail:%@",indexPath.section,indexPath.row, cell.textLabel.text, cell.detailTextLabel.text);
    if (0 == indexPath.section && 0 == indexPath.row)
    {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        [choiceSheet showInView:self.view];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section) {
        return 15;
    }
    return 0;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
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
        if ([self isPhotoLibraryAvailable]) {
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


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    headview.image = editedImage;
    isFromServer = NO;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        NSString *path;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = paths[0];
        BOOL isDir;
        if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            if(!isDir) {
                NSError *error;
                [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
                NSLog(@"%@",error);
            }
        }
        
        path = [path stringByAppendingPathComponent:@"head.jpg"];
        NSData *imageData = UIImageJPEGRepresentation(editedImage,0.5);
        
        [CZJBaseDataInstance uploadUserHeadPic:nil Image:editedImage Success:^(id json) {
            CZJBaseDataInstance.userInfoForm.chezhuHeadImg = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
        } fail:^{
            
        }];
        NSLog(@"Written: %d",[imageData writeToFile:path atomically:YES]);
        
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
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

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end
