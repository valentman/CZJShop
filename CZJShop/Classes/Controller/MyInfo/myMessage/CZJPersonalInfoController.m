//
//  CZJPersonalInfoController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/13/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJPersonalInfoController.h"
#import "UserBaseForm.h"
#import "CZJBaseDataManager.h"
#import "VPImageCropperViewController.h"
#import "CZJDeliveryAddrController.h"
#import "CZJMyCarListController.h"

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
    [self initMyViews];
}

- (void)initMyViews
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //头像
    headview = [[UIImageView alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 51-15, 5, 51, 51)];
    headview.layer.cornerRadius = 25.5;
    headview.clipsToBounds = YES;
    [headview setContentMode:UIViewContentModeScaleAspectFill];
    [headview setTag:255];
    isFromServer = YES;
    
    //昵称
    nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 15, PJ_SCREEN_WIDTH - 100 - 15, 21)];
    nameTextField.placeholder = @"输入真是姓名便于更好的联系";
    nameTextField.textAlignment = NSTextAlignmentRight;
    nameTextField.font = SYSTEMFONT(14);
    nameTextField.textColor = [UIColor darkTextColor];
    [nameTextField setTag:255];
    
    //手机号
    phoneNumTextField = [[UITextField alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - 200 - 15, 15, 200, 21)];
    phoneNumTextField.textAlignment = NSTextAlignmentRight;
    [phoneNumTextField setTag:255];
    phoneNumTextField.font = SYSTEMFONT(14);
    phoneNumTextField.textColor = [UIColor lightGrayColor];
    [phoneNumTextField setEnabled:false];
    
    //保存按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [btn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    btn.layer.cornerRadius = 5.0;
    btn.backgroundColor = CZJREDCOLOR;
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(unLogin:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(50, 5 * 44 + 61 + 15 + 50, PJ_SCREEN_WIDTH - 100, 50);
    [self.tableView addSubview:btn];
    
    
    self.tableView.backgroundColor = CZJNAVIBARBGCOLOR;
    self.view.backgroundColor = CZJNAVIBARBGCOLOR;
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTableView];
    self.navigationController.navigationBarHidden = NO;
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
                [headview sd_setImageWithURL:[NSURL URLWithString:userinfo.headPic] placeholderImage:IMAGENAMED(@"placeholder_personal")];
            }
            
        }
        if (1 == i)
        {
            if (!VIEWWITHTAG(cell, 255))
            {
                [cell addSubview:nameTextField];
            }
            nameTextField.text = userinfo.name;
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
    
    //隐藏车辆cell的分割线（但貌似不行）
    UITableViewCell* cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if (!VIEWWITHTAG(cell2, 9001))
    {
        UILabel* carManageLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 100, 20)];
        carManageLabel.font = SYSTEMFONT(14);
        carManageLabel.text = @"车辆管理:";
        carManageLabel.textColor = RGB(153, 153, 153);
        [cell2 addSubview:carManageLabel];
        carManageLabel.tag = 9001;
    }
    
    cell2.separatorInset = IndentCellSeparator(PJ_SCREEN_WIDTH*0.5);
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
        return 1;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section && 0 == indexPath.row)
    {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        [choiceSheet showInView:self.view];
    }
    if (0 == indexPath.row && 1 == indexPath.section)
    {
//        CZJDeliveryAddrController* deliveryVC = (CZJDeliveryAddrController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"deliveryAddrSBID"];
        CZJMyCarListController* carList = (CZJMyCarListController*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"carListSBID"];
        [self.navigationController pushViewController:carList animated:true];
        
    }
    if (1 == indexPath.section && 1 == indexPath.row)
    {
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (1 == section) {
        return 15;
    }
    return 0;
}


- (void)unLogin:(id)sender
{
    [self.view endEditing:YES];
    NSString* name = nameTextField.text;
    NSString* sexual = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]].detailTextLabel.text;
    NSString* sex;
    if ([sexual isEqualToString:@"保密"]) {
        sex = @"0";
    }
    if ([sexual isEqualToString:@"男"]) {
        sex = @"1";
    }
    if ([sexual isEqualToString:@"女"]) {
        sex = @"2";
    }
    NSDictionary* params = @{@"chezhu.name": name, @"chezhu.sex":sex};
    CZJBaseDataInstance.userInfoForm.name = name;
    CZJBaseDataInstance.userInfoForm.sex = sexual;
    
    [CZJBaseDataInstance updateUserInfo:params Success:^(id json)
     {
         [CZJUtils tipWithText:@"修改成功" andView:self.tableView];
         [self.navigationController popViewControllerAnimated:true];
     }fail:nil];
}



#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([CZJUtils isCameraAvailable] && [CZJUtils doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([CZJUtils isFrontCameraAvailable]) {
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
            CZJBaseDataInstance.userInfoForm.headPic = [[CZJUtils DataFromJson:json] valueForKey:@"msg"];
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

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
