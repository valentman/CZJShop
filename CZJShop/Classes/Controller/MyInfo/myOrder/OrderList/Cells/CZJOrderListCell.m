//
//  CZJOrderListCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderListCell.h"

@interface CZJOrderListCell ()
@property (weak, nonatomic) IBOutlet UIView *storeNameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameViewLeading;
@property (weak, nonatomic) IBOutlet UIView *separatorOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorOneHeight;
@property (weak, nonatomic) IBOutlet UIView *separatorTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorTwoHeight;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateDescLabel;
@property (weak, nonatomic) IBOutlet UIView *noEvalutionContentView;
@property (weak, nonatomic) IBOutlet UIView *normalContentView;
@property (weak, nonatomic) IBOutlet UILabel *payMoneyNumLabel;
@property (weak, nonatomic) IBOutlet UIView *noReceiveButtomView;
@property (weak, nonatomic) IBOutlet UIView *buildingButtomView;
@property (weak, nonatomic) IBOutlet UIView *noPayButtomView;
@property (weak, nonatomic) IBOutlet UIView *noBuildButtomView;
@property (weak, nonatomic) IBOutlet UIView *noEvalutionButtomView;

@property (weak, nonatomic) IBOutlet UIImageView *storeTypeImg;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *goodImg;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsModel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelWidth;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;


- (IBAction)returnGoodsAction:(id)sender;
- (IBAction)showLogisticsInfoAction:(id)sender;
- (IBAction)confirmReceiveGoodsAction:(id)sender;
- (IBAction)checkCarConditionAction:(id)sender;
- (IBAction)showBuildProgressAction:(id)sender;
- (IBAction)cancelOrderAction:(id)sender;
- (IBAction)payAction:(id)sender;
- (IBAction)cancelBuildOrderAction:(id)sender;
- (IBAction)goEvalutionAction:(id)sender;


@end

@implementation CZJOrderListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellModelWithType:(CZJOrderType)type
{
    
}

- (IBAction)returnGoodsAction:(id)sender
{
}

- (IBAction)showLogisticsInfoAction:(id)sender
{
}

- (IBAction)confirmReceiveGoodsAction:(id)sender
{
}

- (IBAction)checkCarConditionAction:(id)sender
{
}

- (IBAction)showBuildProgressAction:(id)sender
{
}

- (IBAction)cancelOrderAction:(id)sender
{
    
}

- (IBAction)payAction:(id)sender
{
}

- (IBAction)cancelBuildOrderAction:(id)sender
{
    
}

- (IBAction)goEvalutionAction:(id)sender
{
}
@end
