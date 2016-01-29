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

@implementation CZJGoodsRecommendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initGoodsRecommendWithDatas:(NSArray*)datas
{
    GoodsRecommendForm * form = datas.firstObject;
    [self.goodImg sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:PNGIMAGE(@"home_btn_xiche")];
    self.goodNameLabel.text = form.itemName;
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%@",form.currentPrice];
    
    if (datas.count > 1)
    {
        GoodsRecommendForm * form2 = datas[1];
        [self.goodImg2 sd_setImageWithURL:[NSURL URLWithString:form2.itemImg] placeholderImage:PNGIMAGE(@"home_btn_xiche")];
        self.goodNameLabel2.text = form2.itemName;
        self.goodPriceLabel2.text = [NSString stringWithFormat:@"￥%@",form2.currentPrice];
    }
}

@end
