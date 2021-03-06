//
//  CZJShoppingCartCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/23/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJShoppingCartCell.h"
#import "WLZ_ChangeCountView.h"

@interface CZJShoppingCartCell ()
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodImage;
@property (weak, nonatomic) IBOutlet UILabel *goodName;
@property (weak, nonatomic) IBOutlet UILabel *itemTypes;
@property (weak, nonatomic) IBOutlet UILabel *goodPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) WLZ_ChangeCountView *changeView;
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
        self.changeView.hidden = YES;
    }
    else
    {//有货
        self.contentView.alpha = 1;
        [_goodsOnSellView setHidden:NO];
        self.soldoutLab.hidden = YES;
        _chooseBtn.enabled=YES;
        self.goodPrice.text = [NSString stringWithFormat:@"￥%@", shoppingGoodsInfo.currentPrice];
        self.choosedCount = [shoppingGoodsInfo.itemCount integerValue];
        
//        if (!VIEWWITHTAG(self.contentView, 998))
//        {
            //加减数量控件
            int width = 90;
            if (iPhone4 || iPhone5)
            {
                width  = width * 0.8;
            }
            int heigh = width/3;
            
            self.changeView = [[WLZ_ChangeCountView alloc]initWithFrame:CGRectMake(PJ_SCREEN_WIDTH - width - 10, (self.frame.size.height + self.goodImage.frame.size.height)*0.5 - heigh, width, heigh) chooseCount:self.choosedCount totalCount: 99];
            self.changeView.tag = 998;
            self.changeView.layer.cornerRadius = 3;
            self.changeView.numberFD.text = [NSString stringWithFormat:@"%ld", self.choosedCount];
            [self.changeView.subButton addTarget:self action:@selector(subButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.changeView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.changeView];
//        }
    }
    [self.goodImage sd_setImageWithURL:[NSURL URLWithString:shoppingGoodsInfo.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    self.chooseBtn.selected = self.goodsInfoForm.isSelect;
    
    [self calculatePriceNumber];
}

//加
- (void)addButtonPressed:(id)sender
{
    ++self.choosedCount ;
    if (self.choosedCount > 1) {
        _changeView.subButton.enabled=YES;
        _changeView.subButton.titleLabel.alpha = 1.0f;
    }
    
    if(self.choosedCount>=99)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"最多支持99个数量!";
        [hud hide:YES afterDelay:2];
        self.choosedCount  = 99;
        _changeView.addButton.enabled = NO;
        _changeView.addButton.titleLabel.alpha = 0.5f;
    }
    
    _changeView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    _changeView.choosedCount = self.choosedCount;
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
        _changeView.subButton.titleLabel.alpha = 0.5f;
    }
    else
    {
        _changeView.addButton.enabled=YES;
        _changeView.addButton.titleLabel.alpha = 1.0f;
        
    }
    _changeView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    _changeView.choosedCount = self.choosedCount;
    self.goodsInfoForm.itemCount = _changeView.numberFD.text;
    self.goodsInfoForm.isSelect=_chooseBtn.selected;
    [self calculatePriceNumber];
}


//计算每个cell自己的小计价格
- (void)calculatePriceNumber
{
    float totalPriceNum = [self.goodsInfoForm.currentPrice floatValue] * self.choosedCount;
    self.totalPrice.text = [NSString stringWithFormat:@"￥%.2f",totalPriceNum];
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
