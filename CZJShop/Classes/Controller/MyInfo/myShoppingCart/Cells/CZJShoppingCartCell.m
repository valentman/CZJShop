//
//  CZJShoppingCartCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJShoppingCartCell.h"
#import "UIImageView+WebCache.h"
#import "WLZ_ChangeCountView.h"

@interface CZJShoppingCartCell ()
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodImage;
@property (weak, nonatomic) IBOutlet UILabel *goodName;
@property (weak, nonatomic) IBOutlet UILabel *itemTypes;
@property (weak, nonatomic) IBOutlet UILabel *goodPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet WLZ_ChangeCountView *changeView;
@property (weak, nonatomic) IBOutlet UILabel *soldoutLab;
@property (weak, nonatomic) IBOutlet UIView *goodsOnSellView;

@property(nonatomic,assign)NSInteger choosedCount;
@property(nonatomic,strong)CZJShoppingGoodsInfoForm *goodsInfoForm;

- (IBAction)clickSelect:(id)sender;
@end

@implementation CZJShoppingCartCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModels:(CZJShoppingGoodsInfoForm*)shoppingGoodsInfo
{
    _soldoutLab.hidden=YES;
    [_goodImage sd_setImageWithURL:nil];
    [_changeView setHidden:YES];
    _changeView = nil;
    _itemTypes.text = nil;
    
    [_chooseBtn setImage:IMAGENAMED(@"commit_btn_circle.png") forState:UIControlStateNormal];
    [_chooseBtn setImage:IMAGENAMED(@"commit_btn_circle_sel.png") forState:UIControlStateSelected];
    _chooseBtn.selected = shoppingGoodsInfo.isSelect;
    
    self.goodsInfoForm = shoppingGoodsInfo;
    self.goodName.text = shoppingGoodsInfo.itemName;
    self.itemTypes.text = shoppingGoodsInfo.itemSku;
    if (self.goodsInfoForm.off)
    {//无货
        [_goodsOnSellView setHidden:YES];
        self.soldoutLab.hidden = NO;
        _chooseBtn.enabled=NO;
        self.contentView.alpha = 0.5;
        if (self.isEdit) {
            //编辑状态
            _chooseBtn.enabled=YES;
            self.contentView.alpha = 1;
        }
    }
    else
    {//有货
        [_goodsOnSellView setHidden:NO];
        self.soldoutLab.hidden = YES;
        _chooseBtn.enabled=YES;
        self.goodPrice.text = [NSString stringWithFormat:@"￥%@", shoppingGoodsInfo.currentPrice];
        self.choosedCount = [shoppingGoodsInfo.itemCount integerValue];
        
        [self.changeView initWithFrame:CGRectMake(20, 8 , 120, 35) chooseCount:1 totalCount: 99].numberFD.text = [NSString stringWithFormat:@"%ld", self.choosedCount];
        [self.changeView.subButton addTarget:self action:@selector(subButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.changeView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.goodImage sd_setImageWithURL:[NSURL URLWithString:shoppingGoodsInfo.itemImg] placeholderImage:nil];
    self.chooseBtn.selected = self.goodsInfoForm.isSelect;
}

//加
- (void)addButtonPressed:(id)sender
{
    ++self.choosedCount ;
    if (self.choosedCount > 1) {
        _changeView.subButton.enabled=YES;
    }
    
    if(self.choosedCount>=99)
    {
        [SVProgressHUD showErrorWithStatus:@"最多支持购买99个"];
        self.choosedCount  = 99;
        _changeView.addButton.enabled = NO;
    }
    
    _changeView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    self.goodsInfoForm.itemCount = _changeView.numberFD.text;
    self.goodsInfoForm.isSelect=_chooseBtn.selected;
    [self calculatePriceNumber];
}


//减
- (void)subButtonPressed:(id)sender
{
    --self.choosedCount ;
    
    if (self.choosedCount <= 1) {
        self.choosedCount= 1;
        _changeView.subButton.enabled=NO;
    }
    else
    {
        _changeView.addButton.enabled=YES;
        
    }
    _changeView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    self.goodsInfoForm.itemCount = _changeView.numberFD.text;
    self.goodsInfoForm.isSelect=_chooseBtn.selected;
    [self calculatePriceNumber];
}


//计算每个cell自己的小计价格
- (void)calculatePriceNumber
{
    NSInteger totalPriceNum = [self.goodsInfoForm.currentPrice integerValue] * self.choosedCount;
    self.totalPrice.text = [NSString stringWithFormat:@"￥%ld",totalPriceNum];
    if (_chooseBtn.selected)
    {//通知controller价格变化
        [self.delegate changePurchaseNumberNotification];
    }
}


- (IBAction)clickSelect:(id)sender
{
    if (!_soldoutLab.hidden && !self.isEdit) {
        return;
    }
    _chooseBtn.selected = !_chooseBtn.selected;
    self.goodsInfoForm.isSelect = _chooseBtn.selected;
    
    if (_changeView.numberFD.text!=nil) {
        self.goodsInfoForm.itemCount = _changeView.numberFD.text;
    }
    
    [self.delegate singleClick:self.goodsInfoForm indexPath:self.indexPath];
    [self.delegate changePurchaseNumberNotification];
}

@end
