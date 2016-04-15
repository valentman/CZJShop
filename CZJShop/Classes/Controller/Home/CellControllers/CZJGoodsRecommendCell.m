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
    NSString* itemOneId;
    NSString* itemTwoId;
    CZJGoodsPromotionType recommendCellPromotionType;
}
@end

@implementation CZJGoodsRecommendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    itemOneId = @"";
    itemTwoId = @"";
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
    GoodsRecommendForm * form = datas.firstObject;
    [self.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderSquare];
    self.goodNameLabel.text = form.itemName;
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",form.currentPrice];
    self.goodPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:self.goodPriceLabel.text WithFont:self.goodPriceLabel.font].width + 5;
    if (CZJGoodsPromotionTypeBaoKuan == promotionType)
    {
        self.goodOriginPriceLabel.hidden = NO;
        NSString* originPriceStr = [NSString stringWithFormat:@"￥%@",form.originalPrice];
        [self.goodOriginPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:originPriceStr]];
        self.goodOriginPriceWidth.constant = [CZJUtils calculateTitleSizeWithString:originPriceStr WithFont:self.goodOriginPriceLabel.font].width + 5;
    }
    itemOneId = form.storeItemPid;
    self.viewTow.hidden = YES;
    if (datas.count > 1)
    {
        self.viewTow.hidden = NO;
        GoodsRecommendForm * form2 = datas[1];
        itemTwoId = form2.storeItemPid;
        [self.goodImg2 sd_setImageWithURL:[NSURL URLWithString:form2.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        self.goodNameLabel2.text = form2.itemName;
        self.goodPriceLabel2.text = [NSString stringWithFormat:@"￥%@",form2.currentPrice];
        self.goodPriceWidth2.constant = [CZJUtils calculateTitleSizeWithString:self.goodPriceLabel2.text WithFont:self.goodPriceLabel2.font].width + 5;
        if (CZJGoodsPromotionTypeBaoKuan == promotionType)
        {
            self.goodOriginPriceLabel2.hidden = NO;
            NSString* orginPriceStr2 = [NSString stringWithFormat:@"￥%@",form2.originalPrice];
            [self.goodOriginPriceLabel2 setAttributedText:[CZJUtils stringWithDeleteLine:orginPriceStr2]];
            self.goodOriginPriceWidth2.constant = [CZJUtils calculateTitleSizeWithString:orginPriceStr2 WithFont:self.goodOriginPriceLabel2.font].width + 5;
        }
    }
    self.goodPriceLabel.keyWord = @"￥";
    self.goodPriceLabel2.keyWord = @"￥";
    self.goodOriginPriceLabel.keyWord = @"￥";
    self.goodOriginPriceLabel2.keyWord = @"￥";
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMenu:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapMenu:(UIGestureRecognizer*)gesture
{
    CGPoint touchPoint = [gesture locationInView:self];
    NSInteger tapIndex = touchPoint.x / (PJ_SCREEN_WIDTH / 2);
    NSString* storeItemID;
    if (0 == tapIndex)
    {
        storeItemID = [NSString stringWithFormat:@"%@",itemOneId];
    }
    else
    {
        storeItemID = [NSString stringWithFormat:@"%@",itemTwoId];
    }
    if (![storeItemID isEqualToString:@""])
    {
        if ([self.delegate respondsToSelector:@selector(clickRecommendCellWithID:)])
        {
            [self.delegate clickRecommendCellWithID:storeItemID];
        }
        if ([self.delegate respondsToSelector:@selector(clickRecommendCellWithID:andPromotionType:)])
        {
            [self.delegate clickRecommendCellWithID:storeItemID andPromotionType:recommendCellPromotionType];
        }
        
    }
}

@end
