//
//  CZJCommitReturnController.m
//  CZJShop
//
//  Created by Joe.Pen on 3/8/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJCommitReturnController.h"
#import "CZJSerFilterTypeChooseCell.h"
#import "CZJOrderReturnedListCell.h"
#import "CZJCommitReturnTypeCell.h"
#import "CZJCommitReturnReasonCell.h"
#import "CZJLeaveMessageCell.h"
#import "CZJOneButtonCell.h"
#import "VPImageCropperViewController.h"
#import "CZJBaseDataManager.h"
#import "NIDropDown.h"
#import "CZJLeaveMessageView.h"

@interface CZJCommitReturnController ()
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
VPImageCropperDelegate,
NIDropDownDelegate,
CZJLeaveMessageViewDelegate
>
{
    __block NSInteger returnType;           //退换货类型
    NSString* chooseTypeStr;
    CZJCommitReturnTypeCell* promptCell;
    
    NSInteger choosedSecionIndex;
    NSMutableArray* returnAbleImgs;
    __block CZJSubmitReturnForm* submitReturnForm;  //退换货数据
    
    NIDropDown* dropDown;
}
@property (strong, nonatomic)UITableView* myTableView;
@property (strong, nonatomic)UIView* backgroundView;
@end

@implementation CZJCommitReturnController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyData];
    [self initViews];
}

- (void)initMyData
{
    submitReturnForm = [[CZJSubmitReturnForm alloc]init];
    submitReturnForm.returnImgs = @"";
    submitReturnForm.returnType = @"1";
    submitReturnForm.returnNote = @"";
    submitReturnForm.returnReason = @"无";
    submitReturnForm.orderItemPid = _returnedGoodsForm.orderItemPid;
    returnAbleImgs = [NSMutableArray array];
}

- (void)initViews
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.backgroundColor = WHITECOLOR;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderReturnedListCell",
                         @"CZJCommitReturnTypeCell",
                         @"CZJCommitReturnReasonCell",
                         @"CZJLeaveMessageCell",
                         @"CZJOneButtonCell"
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    [self.myTableView reloadData];
    
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"退换货";
    self.naviBarView.btnMore.hidden = YES;
    [self.naviBarView.btnMore setBackgroundImage:IMAGENAMED(@"commit_icon_kefu") forState:UIControlStateNormal];
    [self.naviBarView.btnMore addTarget:self action:@selector(contackService:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //背景触摸层
    _backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = RGBA(240, 240, 240, 0);
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [_backgroundView addGestureRecognizer:gesture];
    _backgroundView.hidden = YES;
    [self.view addSubview:_backgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    if (1 == section)
    {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJOrderReturnedListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderReturnedListCell" forIndexPath:indexPath];
            cell.goodNameLabel.text = _returnedGoodsForm.itemName;
            cell.goodModelLabel.text = _returnedGoodsForm.itemSku;
            cell.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",_returnedGoodsForm.currentPrice];
            [cell.goodImg sd_setImageWithURL:[NSURL URLWithString:_returnedGoodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
            cell.returnBtn.hidden = YES;
            cell.returnStateLabel.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJSerFilterTypeChooseCell* cell = [[CZJSerFilterTypeChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell4"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell setButtonDatas:@[@"退货",@"换货"] WithType:kCZJSerfilterTypeChooseCellTypeReturnGoods];
            CZJButtonBlock buttonHandler = ^(UIButton* button){
                returnType = button.tag;
                if ([button.titleLabel.text isEqualToString:@"退货"])
                {
                    returnType = 0;
                    submitReturnForm.returnType = @"1";
                    promptCell.promptLabel.text = @"您选择了退货，请与卖家协商达成退货。";
                }
                if ([button.titleLabel.text isEqualToString:@"换货"])
                {
                    returnType = 1;
                    submitReturnForm.returnType = @"2";
                    promptCell.promptLabel.text = @"您选择了换货，请与卖家协商达成退货。";
                }
            };
            [cell setButtonBlock:buttonHandler];
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        if (2 == indexPath.row)
        {
            promptCell = [tableView dequeueReusableCellWithIdentifier:@"CZJCommitReturnTypeCell" forIndexPath:indexPath];
            promptCell.backgroundColor = WHITECOLOR;
            return promptCell;
        }
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            CZJCommitReturnReasonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCommitReturnReasonCell" forIndexPath:indexPath];
            CAShapeLayer* trangle = [CZJUtils creatIndicatorWithColor:RGB(100, 100, 100) andPosition:CGPointMake(PJ_SCREEN_WIDTH - 50, 15)];
            [cell.returnTypeBtn.layer addSublayer:trangle];
            [cell.returnTypeBtn addTarget:self action:@selector(returnTypeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            cell.returnTypeLabel.text = submitReturnForm.returnReason;
            
            [cell.picLoadView removeAllSubViewsExceptView:cell.picBTn];
            [cell.picBTn addTarget:self action:@selector(picBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            int divide = (iPhone5 || iPhone4) ? 3 : 4;
            for (int i = 0; i < returnAbleImgs.count; i++)
            {
                NSString* imgUrl = returnAbleImgs[i];
                CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:divide];
                CZJDeletableImageView* picImage = [[CZJDeletableImageView alloc]initWithFrame:imageFrame andImageName:imgUrl];
                [picImage.deleteButton addTarget:self action:@selector(picViewDeleteBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
                [picImage.deleteButton setTag:indexPath.section];
                [cell.picLoadView addSubview:picImage];
            }
            CGRect picBtnFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:(int)returnAbleImgs.count divide:divide];
            cell.picBtnLeading.constant = picBtnFrame.origin.x;
            cell.picBtnTop.constant = picBtnFrame.origin.y;

            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
        if (1 == indexPath.row)
        {
            CZJLeaveMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJLeaveMessageCell" forIndexPath:indexPath];
            cell.leaveMessageView.hidden = NO;
            if (![submitReturnForm.returnNote isEqualToString:@""])
            {
                cell.leaveMessageView.hidden = YES;
                cell.leaveMessageLabel.text = submitReturnForm.returnNote;
                cell.leaveMessageLayoutHeight.constant = [CZJUtils calculateTitleSizeWithString:submitReturnForm.returnNote AndFontSize:12].height + 10;
            }
            cell.separatorInset = HiddenCellSeparator;
            return cell;

        }
        if (2 == indexPath.row)
        {
            CZJOneButtonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOneButtonCell" forIndexPath:indexPath];
            [cell.theBtn addTarget:self action:@selector(submitMyReturn:) forControlEvents:UIControlEventTouchUpInside];
            cell.backgroundColor = CLEARCOLOR;
            cell.separatorInset = HiddenCellSeparator;
            return cell;
        }
    }
    return nil;
}

- (void)picViewDeleteBtnHandler:(UIButton*)sender
{
    NSInteger indexSection = sender.tag;
    CZJDeletableImageView* picImage = (CZJDeletableImageView*)[sender superview];
    [picImage removeFromSuperview];
    [returnAbleImgs removeObject:picImage.imgName];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexSection] withRowAnimation:UITableViewRowAnimationAutomatic];
}



#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 100;
        }
        if (1 == indexPath.row)
        {
            return 80;
        }
        if (2 == indexPath.row)
        {
            return 56;
        }
    }
    if (1 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return 150;
        }
        if (1 == indexPath.row)
        {
            float height = [CZJUtils calculateTitleSizeWithString:submitReturnForm.returnNote AndFontSize:12].height;
            return 50 + height;
        }
        if (2 == indexPath.row)
        {
            return 100;
        }
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.section && 1 == indexPath.row)
    {
        CZJLeaveMessageView* leaveMessage = (CZJLeaveMessageView*)[CZJUtils getViewControllerFromStoryboard:kCZJStoryBoardFileMain andVCName:@"leaveMessageSBID"];
        leaveMessage.delegate = self;
        leaveMessage.leaveMesageStr = submitReturnForm.returnNote;
        [self.navigationController pushViewController:leaveMessage animated:YES];
    }
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
                          [weak refreshPic:[dict valueForKey:@"url"]];
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
    submitReturnForm.returnNote = textView.text;
    DLog(@"%@",textView.text);
}


- (void)textViewDidChange:(UITextView *)textView
{
    DLog(@"%@",textView.text);
}


- (void)picBtnTouched:(id)sender
{
    choosedSecionIndex = ((UIButton*)sender).tag;
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)refreshPic:(NSString*)picImg
{
    [returnAbleImgs addObject:picImg];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark- 提交退货申请
- (void)submitMyReturn:(id)sender
{
    submitReturnForm.returnImgs = [returnAbleImgs componentsJoinedByString:@","];
    NSDictionary* dict = submitReturnForm.keyValues;
    DLog(@"退货%@",[dict description]);
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:@{@"paramJson" : [CZJUtils JsonFromData:dict]} success:^(id json){
         [CZJUtils tipWithText:@"提交退货信息成功，请耐心等待处理！" andView:nil];
        [weak.navigationController popViewControllerAnimated:YES];
     }  fail:^{
         
     } andServerAPI:kCZJServerAPISubmitReturnOrder];
}

- (void)returnTypeBtnTouched:(UIButton*)sender
{
    NSArray * arr = @[@{@"收到的商品与描述不符" : @""},
                      @{@"商品质量问题":@""},
                      @{@"盗版/假货" :@""},
                      @{@"拍错/多拍" :@""}];
    if(dropDown == nil) {
        CGRect frame = [self.myTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        CGRect rect = CGRectMake(15, 20 + 64 + frame.origin.y, PJ_SCREEN_WIDTH - 30, 160);
        _backgroundView.hidden = NO;
        dropDown = [[NIDropDown alloc]showDropDown:_backgroundView Frame:rect WithObjects:arr  andType:CZJNIDropDownTypeCustomize];
         YES;
        dropDown.data = submitReturnForm.returnReason;
        dropDown.clipsToBounds = YES;
        dropDown.layer.cornerRadius = 5;
        dropDown.layer.borderWidth = 0.5;
        dropDown.layer.borderColor = RGB(128, 128, 128).CGColor;
        dropDown.delegate = self;
    }
}




#pragma mark- NIDropDownDelegate(更多按钮弹出框回调)
- (void) niDropDownDelegateMethod:(NSString*)btnStr
{
    submitReturnForm.returnReason = btnStr;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self tapBackground:nil];
}

- (void)tapBackground:(UITapGestureRecognizer *)paramSender
{
    if (dropDown)
    {
        _backgroundView.hidden = YES;
        [dropDown hideDropDown:paramSender];
        dropDown = nil;
    }
}

- (void)contackService:(UIButton*)sender
{
    DLog(@"联系客服");
}


- (void)clickConfirmMessage:(NSString*)message
{
    submitReturnForm.returnNote = message;
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
@end
