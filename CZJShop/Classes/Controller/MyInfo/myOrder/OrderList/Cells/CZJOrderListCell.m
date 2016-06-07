//
//  CZJOrderListCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListCell.h"


@interface CZJOrderListCell ()
{
    CZJOrderListForm* _currentListForm;
}
@property (weak, nonatomic) IBOutlet UIView *storeNameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameViewLeading;
@property (weak, nonatomic) IBOutlet UIView *separatorOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorOneHeight;
@property (weak, nonatomic) IBOutlet UIView *separatorTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorTwoHeight;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateDescLabel;
@property (weak, nonatomic) IBOutlet UIView *noEvalutionContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *normalContentView;
@property (weak, nonatomic) IBOutlet UILabel *payMoneyNumLabel;

@property (weak, nonatomic) IBOutlet UIView *noReceiveButtomView;
@property (weak, nonatomic) IBOutlet UIView *buildingNoPaidButtomView;
@property (weak, nonatomic) IBOutlet UIView *noPayButtomView;
@property (weak, nonatomic) IBOutlet UIView *noBuildButtomView;
@property (weak, nonatomic) IBOutlet UIView *noEvalutionButtomView;
@property (weak, nonatomic) IBOutlet UIView *buildingPaidButtomView;
@property (weak, nonatomic) IBOutlet UIView *buildingNoPaidButtomViews;

@property (weak, nonatomic) IBOutlet UIImageView *storeTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsModel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@property (weak, nonatomic) IBOutlet UIButton *viewBuildingProgressBtn;
@property (weak, nonatomic) IBOutlet UIImageView *completeImg;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;

//可退换货列表按钮
- (IBAction)returnGoodsAction:(id)sender;
//确认收货按钮
- (IBAction)confirmReceiveGoodsAction:(id)sender;
//查看车检情况按钮
- (IBAction)checkCarConditionAction:(id)sender;
//查看施工进度按钮
- (IBAction)showBuildProgressAction:(id)sender;
//取消订单按钮
- (IBAction)cancelOrderAction:(id)sender;
//付款按钮
- (IBAction)payAction:(id)sender;
//去评价按钮
- (IBAction)goEvalutionAction:(id)sender;
//待付款选项选择按钮
- (IBAction)noPaySelectAction:(id)sender;


@end

@implementation CZJOrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.separatorOneHeight.constant = 0.5;
    self.separatorTwoHeight.constant = 0.5;
    self.stateDescLabel.hidden = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)generateQRCodeImage:(NSString*)ShareCode andTarget:(UIImageView*)QRCodeImage
{
    //二维码滤镜
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    [filter setDefaults];
    
    //将字符串转换成NSData
    NSData *data=[ShareCode dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    BACK(^(){
        UIImage* tmpImag=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:180];
        
        MAIN(^(){
            QRCodeImage.image = tmpImag;
//            CGRect qrFram = QRCodeImage.frame;
//            DLog(@"qrframe: %f",qrFram.size.width);
//            UIImageView* centerImage = [[UIImageView alloc]initWithImage:IMAGENAMED(@"icon-small-40")];
//            centerImage.layer.cornerRadius = 5;
//            centerImage.clipsToBounds = YES;
//            [centerImage setSize:CGSizeMake(40, 40)];
//            [centerImage setPosition:CGPointMake(0.5*QRCodeImage.frame.size.width, 0.5* QRCodeImage.frame.size.height) atAnchorPoint:CGPointMake(0.5, 0.5)];
//            [QRCodeImage addSubview:centerImage];
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


- (void)setCellModelWithType:(CZJOrderListForm*)listForm andType:(CZJOrderType)orderType
{
    _currentListForm = listForm;
    //先全部初始化隐藏
    self.noReceiveButtomView.hidden = YES;
    self.buildingNoPaidButtomView.hidden = YES;
    self.noPayButtomView.hidden = YES;
    self.noBuildButtomView.hidden = YES;
    self.noEvalutionButtomView.hidden = YES;
    self.buildingPaidButtomView.hidden = YES;
    self.buildingNoPaidButtomViews.hidden = YES;
    self.completeImg.hidden = YES;
    self.noEvalutionContentView.hidden = YES;
    self.normalContentView.hidden = YES;
    
    //通用,暂时屏蔽付款功能
//    if (CZJOrderTypeNoPay == orderType)
//    {
//        self.storeNameViewLeading.constant = 40;
//        self.selectBtn.selected = listForm.isSelected;
//    }
    self.payMoneyNumLabel.text = [NSString stringWithFormat:@"￥%@",listForm.orderMoney ];
    self.storeNameLabel.text = listForm.storeName;
    [self.storeTypeImg setImage:IMAGENAMED(@"commit_icon_shop")];
    
    //内容视图根据商品的个数来决定显示详情，还是显示图片组
    if (listForm.items.count > 1)
    {
        self.normalContentView.hidden = NO;
        for ( int i= 0; i <listForm.items.count; i++)
        {
            CZJOrderGoodsForm* goodsForm = (CZJOrderGoodsForm*)listForm.items[i];
            UIImageView* goodsImage = [[UIImageView alloc]initWithFrame:CGRectMake(10 + 88 * i, 5, 78, 78)];
            [goodsImage sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
            [self.normalContentView addSubview:goodsImage];
        }
    }
    else
    {
        self.noEvalutionContentView.hidden = NO;
        CZJOrderGoodsForm* goodsForm = (CZJOrderGoodsForm*)listForm.items[0];
        [self.goodImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        self.goodsNameLabel.text = goodsForm.itemName;
        self.goodsModel.text = goodsForm.itemSku;
        self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[goodsForm.currentPrice floatValue]];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:self.priceLabel.text AndFontSize:14];
        self.priceLabelWidth.constant = priceSize.width + 20;
        self.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
    }
    
    //-----------------------------------未付款----------------------------------
    if (!listForm.paidFlag)
    {
        //区分是服务和商品：type==0为商品，type==1为服务
        if (0 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工";
            }
            else if (2 == [listForm.status integerValue])
            {
                
            }
            else if (3 == [listForm.status integerValue])
            {
                
            }
        }
        else if (1 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
                
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工";
                if (CZJOrderTypeNoBuild == orderType)
                {
                    self.buildingNoPaidButtomViews.hidden = NO;
                }
                else
                {
                    self.buildingNoPaidButtomViews.hidden = NO;
                }
            }
            else if (2 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"施工中";
                if (CZJOrderTypeNoPay == orderType)
                {
                    self.buildingNoPaidButtomView.hidden = NO;
                    self.viewBuildingProgressBtn.hidden = YES;
                }
                if (CZJOrderTypeNoBuild == orderType)
                {
                    self.buildingPaidButtomView.hidden = NO;
                }
                if (CZJOrderTypeAll == orderType)
                {
                    self.buildingNoPaidButtomView.hidden = NO;
                }
            }
            else if (3 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"已施工";
                self.completeImg.hidden = YES;
                if (CZJOrderTypeAll == orderType)
                {
                    self.buildingPaidButtomView.hidden = NO;
                }
                if (CZJOrderTypeNoPay == orderType)
                {
                    self.buildingPaidButtomView.hidden = NO;
                    self.viewBuildingProgressBtn.hidden = YES;
                }
                if (CZJOrderTypeNoBuild == orderType)
                {
                    self.buildingPaidButtomView.hidden = NO;
                }
            }
        }
        else if (2 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
            }
            else if (2 == [listForm.status integerValue])
            {
            }
            else if (3 == [listForm.status integerValue])
            {
            }
        }
    }
    
    //-----------------------------------已付款----------------------------------
    else
    {
        if (0 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待出库";
                
            }
            else if (2 == [listForm.status integerValue])
            {
                
            }
            else if (3 == [listForm.status integerValue])
            {
                self.noReceiveButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"已发货";
            }
            else if (4 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_wancheng")];
                self.noEvalutionButtomView.hidden = listForm.evaluated;
            }
            else if (5 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_cancel")];
            }
        }
        else if (1 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工";
                [self generateQRCodeImage:[NSString stringWithFormat:@"%@,%@",listForm.orderNo,listForm.storeId] andTarget:_QRCodeImage];
            }
            else if (1 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工";
            }
            else if (2 == [listForm.status integerValue])
            {
                self.buildingPaidButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"施工中";
            }
            else if (3 == [listForm.status integerValue])
            {
                self.buildingPaidButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"已施工";
            }
            else if (4 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_wancheng")];
                self.noEvalutionButtomView.hidden = listForm.evaluated;
                
            }
            else if (5 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_cancel")];
            }
        }
        else if (2 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
            }
            else if (1 == [listForm.status integerValue])
            {
            }
            else if (2 == [listForm.status integerValue])
            {
                if (CZJOrderTypeNoBuild == orderType)
                {
                }
                if (CZJOrderTypeAll == orderType)
                {
                }
            }
            else if (3 == [listForm.status integerValue])
            {
                
            }
            else if (4 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_wancheng")];
                self.noEvalutionButtomView.hidden = listForm.evaluated;
            }
            else if (5 == [listForm.status integerValue])
            {
                self.stateDescLabel.hidden = YES;
                self.stateDescLabel.text = @"";
                self.completeImg.hidden = NO;
                [self.completeImg setImage:IMAGENAMED(@"order_icon_cancel")];
            }
        }
    }
}

- (IBAction)returnGoodsAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeReturnAble andOrderForm:_currentListForm];
}

- (IBAction)confirmReceiveGoodsAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeConfirm andOrderForm:_currentListForm];
}

- (IBAction)checkCarConditionAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeCheckCar andOrderForm:_currentListForm];
}

- (IBAction)showBuildProgressAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeShowBuildingPro andOrderForm:_currentListForm];
}

- (IBAction)cancelOrderAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeCancel andOrderForm:_currentListForm];
}

- (IBAction)payAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypePay andOrderForm:_currentListForm];
}

- (IBAction)goEvalutionAction:(id)sender
{
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeGoEvaluate andOrderForm:_currentListForm];
}

- (IBAction)noPaySelectAction:(id)sender
{
    ((UIButton*)sender).selected = !((UIButton*)sender).selected;
    [self.delegate clickPaySelectButton:sender andOrderForm:_currentListForm];
}
@end
