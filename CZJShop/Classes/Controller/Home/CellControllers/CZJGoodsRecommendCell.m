//
//  CZJGoodsRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsRecommendCell.h"
#import "CZJGoodsRecoCollectionCell.h"
#import "HomeForm.h"

@interface CZJGoodsRecommendCell()
{
    GoodsRecommendForm * goodRecoForm1;
    GoodsRecommendForm * goodRecoForm2;
    NSString* itemTwoId;
    CZJGoodsPromotionType recommendCellPromotionType;
}
@end

@implementation CZJGoodsRecommendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.goodPriceLabel.keyWordFont = SYSTEMFONT(12);
    self.goodPriceLabel2.keyWordFont = SYSTEMFONT(12);
    self.goodOriginPriceLabel.keyWordFont = SYSTEMFONT(12);
    self.goodOriginPriceLabel2.keyWordFont = SYSTEMFONT(12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)initGoodsRecommendWithDatas:(NSArray*)datas
{
    [self initGoodsRecommendWithDatas:datas andPromotionType:CZJGoodsPromotionTypeGeneral];
}

- (void)initGoodsRecommendWithDatas:(NSArray*)datas andPromotionType:(CZJGoodsPromotionType)promotionType
{
    self.goodOriginPriceLabel.hidden = YES;
    self.goodOriginPriceLabel2.hidden = YES;
    recommendCellPromotionType = promotionType;
    self.isInit = YES;
    goodRecoForm1 = datas.firstObject;
    if (goodRecoForm1)
    {
        self.viewOne.hidden = NO;
    }
    [self.goodImg sd_setImageWithURL:[NSURL URLWithString:goodRecoForm1.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    self.goodNameLabel.text = goodRecoForm1.itemName;
    CGSize goodNameSize = [CZJUtils calculateStringSizeWithString:goodRecoForm1.itemName Font:self.goodNameLabel.font Width:(PJ_SCREEN_WIDTH - 15)*0.5 - 10];
    self.goodNameLabelHeight.constant = goodNameSize.height > 20 ? 40 : 20;
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",goodRecoForm1.currentPrice];
    
    self.goodPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:self.goodPriceLabel.text WithFont:self.goodPriceLabel.font].width + 5;
    if (CZJGoodsPromotionTypeBaoKuan == promotionType)
    {
        self.goodOriginPriceLabel.hidden = NO;
        NSString* originPriceStr = [NSString stringWithFormat:@"￥%@",goodRecoForm1.originalPrice];
        [self.goodOriginPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:originPriceStr]];
        self.goodOriginPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:originPriceStr WithFont:self.goodOriginPriceLabel.font].width + 5;
    }
    self.viewTow.hidden = YES;
    if (datas.count > 1)
    {
        self.viewTow.hidden = NO;
        goodRecoForm2 = datas[1];
        [self.goodImg2 sd_setImageWithURL:[NSURL URLWithString:goodRecoForm2.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        self.goodNameLabel2.text = goodRecoForm2.itemName;
        CGSize goodNameSize2 = [CZJUtils calculateStringSizeWithString:goodRecoForm2.itemName Font:self.goodNameLabel2.font Width:(PJ_SCREEN_WIDTH - 15)*0.5 - 10];
        self.goodNameLabelheight2.constant = goodNameSize2.height > 20 ? 40 : 20;
        self.goodPriceLabel2.text = [NSString stringWithFormat:@"￥%@",goodRecoForm2.currentPrice];
        
        self.goodPriceWidth2.constant = [CZJUtils calculateTitleSizeWithString:self.goodPriceLabel2.text WithFont:self.goodPriceLabel2.font].width + 5;
        if (CZJGoodsPromotionTypeBaoKuan == promotionType)
        {
            self.goodOriginPriceLabel2.hidden = NO;
            NSString* orginPriceStr2 = [NSString stringWithFormat:@"￥%@",goodRecoForm2.originalPrice];
            [self.goodOriginPriceLabel2 setAttributedText:[CZJUtils stringWithDeleteLine:orginPriceStr2]];
            self.goodOriginPriceWidth2.constant = [CZJUtils calculateTitleSizeWithString:orginPriceStr2 WithFont:self.goodOriginPriceLabel2.font].width + 5;
        }
    }
    self.goodPriceLabel.keyWord = @"￥";
    self.goodPriceLabel2.keyWord = @"￥";
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMenu:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapMenu:(UIGestureRecognizer*)gesture
{
    CGPoint touchPoint = [gesture locationInView:self];
    NSInteger tapIndex = touchPoint.x / (PJ_SCREEN_WIDTH / 2);
    NSString* storeItemID;
    GoodsRecommendForm* tmpGoodReco = [[GoodsRecommendForm alloc]init];
    if (0 == tapIndex)
    {
        tmpGoodReco = goodRecoForm1;
    }
    else
    {
        tmpGoodReco = goodRecoForm2;
    }
    if (![storeItemID isEqualToString:@""])
    {
        if ([self.delegate respondsToSelector:@selector(clickRecommendCellWithID:)])
        {
            [self.delegate clickRecommendCellWithID:tmpGoodReco];
        }
        if ([self.delegate respondsToSelector:@selector(clickRecommendCellWithID:andPromotionType:)])
        {
            [self.delegate clickRecommendCellWithID:tmpGoodReco andPromotionType:recommendCellPromotionType];
        }
        
    }
}

@end
