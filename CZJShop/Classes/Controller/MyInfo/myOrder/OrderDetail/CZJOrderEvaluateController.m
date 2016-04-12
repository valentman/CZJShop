//
//  CZJOrderEvaluateController.m
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderEvaluateController.h"
#import "CZJOrderEvaluateCell.h"
#import "CZJOrderEvalutateAllCell.h"
#import "CZJOrderForm.h"
#import "CZJEvaluateForm.h"
#import "VPImageCropperViewController.h"
#import "CZJBaseDataManager.h"

@interface CZJOrderEvaluateController ()
<
UITextViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
VPImageCropperDelegate,
CZJStarRateViewDelegate
>
{
    CZJMyEvaluationForm* myEvaluationForm;
    NSInteger choosedSecionIndex;
}
@property (strong, nonatomic)UITableView* myTableView;
@end

@implementation CZJOrderEvaluateController

- (void)viewDidLoad {
    [super viewDidLoad];
    TICK;
    [self initDatas];
    [self initViews];
    TOCK;
}

- (void)initDatas
{
    myEvaluationForm = [[CZJMyEvaluationForm alloc] init];
    myEvaluationForm.orderNo = self.orderDetailForm.orderNo;
    myEvaluationForm.storeId = self.orderDetailForm.storeId;
    NSString* head = CZJBaseDataInstance.userInfoForm.chezhuHeadImg;
    myEvaluationForm.head = head.length > 0 ? head : @"";
    myEvaluationForm.name = CZJBaseDataInstance.userInfoForm.chezhuName;
    myEvaluationForm.orderTime = self.orderDetailForm.createTime;
    myEvaluationForm.descScore = @"5";
    myEvaluationForm.serviceScore = @"5";
    myEvaluationForm.deliveryScore = @"5";
    myEvaluationForm.environmentScore = @"5";
    myEvaluationForm.items = [NSMutableArray array];
    for (CZJOrderGoodsForm* goodsForm in self.orderDetailForm.items)
    {
        CZJMyEvaluationGoodsForm* mygoodsform = [[CZJMyEvaluationGoodsForm alloc] init];
        mygoodsform.storeItemPid = goodsForm.storeItemPid;
        mygoodsform.itemName = goodsForm.itemName;
        mygoodsform.itemImg = goodsForm.itemImg;
        mygoodsform.counterKey = goodsForm.counterKey;
        mygoodsform.itemSku = goodsForm.itemSku;
        mygoodsform.score = @"5";
        mygoodsform.message = @"";
        mygoodsform.itemType = goodsForm.itemType;
        mygoodsform.evalImgs = [NSMutableArray array];
        [myEvaluationForm.items addObject:mygoodsform];
    }
}

- (void)initViews
{
    [self addCZJNaviBarView:CZJNaviBarViewTypeGeneral];
    self.naviBarView.mainTitleLabel.text = @"发表评价";
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, PJ_SCREEN_HEIGHT - StatusBar_HEIGHT - NavigationBar_HEIGHT) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJOrderEvaluateCell",
                         @"CZJOrderEvalutateAllCell"
                         ];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    [self.myTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)picBtnTouched:(id)sender
{
    [self.view endEditing:YES];
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
    CZJMyEvaluationGoodsForm* returnedListForm = (CZJMyEvaluationGoodsForm*)myEvaluationForm.items[choosedSecionIndex];
    [returnedListForm.evalImgs addObject:picImg];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:choosedSecionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)addMyComment:(id)sender
{
    NSDictionary* dict = myEvaluationForm.keyValues;
    DLog(@"发表评价%@",[dict description]);
    __weak typeof(self) weak = self;
    [CZJBaseDataInstance generalPost:@{@"paramJson" : [CZJUtils JsonFromData:dict]} success:^(id json)
    {
        NSDictionary* dicts = [CZJUtils DataFromJson:json];
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [dicts valueForKey:@"msg"];
        [hud hide:YES afterDelay:1.5];
        hud.completionBlock = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kCZJNotifiRefreshOrderlist object:nil];
            [weak.navigationController popViewControllerAnimated:YES];
        };
    }  fail:^{
        
    } andServerAPI:kCZJServerAPISubmitComment];
}


#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderDetailForm.items.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 <= indexPath.section && indexPath.section < self.orderDetailForm.items.count)
    {
        CZJMyEvaluationGoodsForm* returnedListForm = (CZJMyEvaluationGoodsForm*)myEvaluationForm.items[indexPath.section];
        
        CZJOrderEvaluateCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderEvaluateCell" forIndexPath:indexPath];
        cell.messageTextField.delegate = self;
        cell.starView.delegate = self;
        cell.messageTextField.text = returnedListForm.message? returnedListForm.message : @"";
        cell.starView.ownerObject = returnedListForm;
        [cell.picBTn addTarget:self action:@selector(picBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.goodsImg sd_setImageWithURL:[NSURL URLWithString:returnedListForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        cell.goodsNameLabel.text = returnedListForm.itemName;
        [cell.picBTn setTag:indexPath.section];
        [cell.messageTextField setTag:indexPath.section];
        
        [cell.picLoadView removeAllSubViewsExceptView:cell.picBTn];
        
        int divide = (iPhone5 || iPhone4) ? 3 : 4;
        for (int i = 0; i < returnedListForm.evalImgs.count; i++)
        {
            NSString* imgUrl = returnedListForm.evalImgs[i];
            CGRect imageFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:i divide:divide];
            CZJDeletableImageView* picImage = [[CZJDeletableImageView alloc]initWithFrame:imageFrame andImageName:imgUrl];
            [picImage.deleteButton addTarget:self action:@selector(picViewDeleteBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
            [picImage.deleteButton setTag:indexPath.section];
            [cell.picLoadView addSubview:picImage];
        }
        CGRect picBtnFrame = [CZJUtils viewFramFromDynamic:CZJMarginMake(15, 10) size:CGSizeMake(78, 78) index:(int)returnedListForm.evalImgs.count divide:divide];
        cell.picBtnLeading.constant = picBtnFrame.origin.x;
        cell.picBtnTop.constant = picBtnFrame.origin.y;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == self.orderDetailForm.items.count)
    {
        CZJOrderEvalutateAllCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJOrderEvalutateAllCell" forIndexPath:indexPath];
        cell.descView.delegate = self;
        cell.descView.ownerObject = @"描述相符";
        cell.serviceView.delegate = self;
        cell.serviceView.ownerObject = @"服务态度";
        cell.evirView.delegate = self;
        cell.evirView.ownerObject = @"发货速度";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == self.orderDetailForm.items.count + 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"clearCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"clearCell"];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = CZJREDCOLOR;
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = SYSTEMFONT(15);
            [button addTarget:self action:@selector(addMyComment:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"发表评价" forState:UIControlStateNormal];
            button.layer.cornerRadius = 2.5;
            CGRect btnFrame = CGRectMake(50, 30, PJ_SCREEN_WIDTH - 100, 45);
            button.frame = btnFrame;
            cell.backgroundColor = RGB(245, 245, 245);
            [cell addSubview:button];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (void)picViewDeleteBtnHandler:(UIButton*)sender
{
    NSInteger indexSection = sender.tag;
    CZJDeletableImageView* picImage = (CZJDeletableImageView*)[sender superview];
    [picImage removeFromSuperview];
    CZJMyEvaluationGoodsForm* returnedListForm = (CZJMyEvaluationGoodsForm*)myEvaluationForm.items[indexSection];
    [returnedListForm.evalImgs removeObject:picImage.imgName];
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:indexSection] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 <= indexPath.section && indexPath.section < self.orderDetailForm.items.count)
    {
         CZJMyEvaluationGoodsForm* returnedListForm = (CZJMyEvaluationGoodsForm*)myEvaluationForm.items[indexPath.section];
        int row = ceil(returnedListForm.evalImgs.count / Divide);
        return 307 + 78 * row;
    }
    if (indexPath.section == self.orderDetailForm.items.count)
    {
        return 159;
    }
    if (indexPath.section == self.orderDetailForm.items.count + 1)
    {
        return 100;
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

//去掉tableview中section的headerview粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark- CZJStarRateViewDelegate
- (void)starRateView:(CZJStarRageView *)starRateView didChangedScorePercentageTo:(CGFloat)percentage
{
    NSString* scoreStr = [NSString stringWithFormat:@"%.f", fabs(percentage / 0.2)];
    id obj = starRateView.ownerObject;
    if ([obj isKindOfClass:[CZJMyEvaluationGoodsForm class]])
    {
        ((CZJMyEvaluationGoodsForm*)obj).score = scoreStr;
    }
    else if ([obj isKindOfClass:[NSString class]])
    {
        NSString* descStr = (NSString*)obj;
        if ([descStr isEqualToString:@"描述相符"])
        {
            myEvaluationForm.descScore = scoreStr;
        }
        if ([descStr isEqualToString:@"服务态度"])
        {
            myEvaluationForm.serviceScore = scoreStr;
        }
        if ([descStr isEqualToString:@"发货速度"])
        {
            myEvaluationForm.deliveryScore = scoreStr;
        }
        myEvaluationForm.environmentScore = @"5";
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
    NSInteger indexSection = textView.tag;
    CZJMyEvaluationGoodsForm* returnedListForm = (CZJMyEvaluationGoodsForm*)myEvaluationForm.items[indexSection];
    returnedListForm.message = textView.text;
    DLog(@"%@",textView.text);
}


- (void)textViewDidChange:(UITextView *)textView
{
    DLog(@"%@",textView.text);
}

@end
