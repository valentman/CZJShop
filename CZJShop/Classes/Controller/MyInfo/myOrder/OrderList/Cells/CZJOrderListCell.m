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
    
    self.noEvalutionContentView.hidden = YES;
    self.normalContentView.hidden = YES;
    //通用
    if (CZJOrderTypeNoPay == orderType)
    {
        self.storeNameViewLeading.constant = 40;
    }
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
            [goodsImage sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
            [self.normalContentView addSubview:goodsImage];
        }
    }
    else
    {
        self.noEvalutionContentView.hidden = NO;
        CZJOrderGoodsForm* goodsForm = (CZJOrderGoodsForm*)listForm.items[0];
        [self.goodImg sd_setImageWithURL:[NSURL URLWithString:goodsForm.itemImg] placeholderImage:IMAGENAMED(@"home_btn_xiche")];
        self.goodsNameLabel.text = goodsForm.itemName;
        self.goodsModel.text = goodsForm.itemSku;
        self.priceLabel.text = [NSString stringWithFormat:@"￥%@",goodsForm.currentPrice];
        CGSize priceSize = [CZJUtils calculateTitleSizeWithString:[NSString stringWithFormat:@"￥%@",goodsForm.currentPrice] AndFontSize:14];
        self.priceLabelWidth.constant = priceSize.width + 5;
        self.numLabel.text = [NSString stringWithFormat:@"×%@",goodsForm.itemCount];
    }
    
    if (!listForm.paidFlag)
    {
        //区分是服务和商品：type==0为商品，type==1为服务
        if (0 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noPayButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
                self.noPayButtomView.hidden = NO;
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
                self.noPayButtomView.hidden = NO;
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
                    self.noPayButtomView.hidden = NO;
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
                
            }
        }
    }
    else
    {
        if (0 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noPayButtomView.hidden = NO;
            }
            else if (1 == [listForm.status integerValue])
            {
                
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
                self.noEvalutionButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待评价";
            }
        }
        else if (1 == [listForm.type integerValue])
        {
            if (0 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工(等到店)";
            }
            else if (1 == [listForm.status integerValue])
            {
                self.noBuildButtomView.hidden = NO;
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"待施工(等门店)";
                
            }
            else if (2 == [listForm.status integerValue])
            {
                if (CZJOrderTypeNoBuild == orderType)
                {
                    self.buildingPaidButtomView.hidden = NO;
                }
                if (CZJOrderTypeAll == orderType)
                {
                    self.buildingNoPaidButtomView.hidden = NO;
                }
                
                self.stateDescLabel.hidden = NO;
                self.stateDescLabel.text = @"施工中";
            }
            else if (3 == [listForm.status integerValue])
            {
                
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
    [self.delegate clickOrderListCellAction:CZJOrderListCellBtnTypeSelectToPay andOrderForm:_currentListForm];
}
@end
