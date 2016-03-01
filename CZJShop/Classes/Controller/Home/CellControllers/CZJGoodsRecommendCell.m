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
}
@end

@implementation CZJGoodsRecommendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    itemOneId = @"";
    itemTwoId = @"";
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
    itemOneId = form.storeItemPid;
    self.viewTow.hidden = YES;
    if (datas.count > 1)
    {
        self.viewTow.hidden = NO;
        GoodsRecommendForm * form2 = datas[1];
        itemTwoId = form2.storeItemPid;
        [self.goodImg2 sd_setImageWithURL:[NSURL URLWithString:form2.itemImg] placeholderImage:PNGIMAGE(@"home_btn_xiche")];
        self.goodNameLabel2.text = form2.itemName;
        self.goodPriceLabel2.text = [NSString stringWithFormat:@"￥%@",form2.currentPrice];
    }
    
    
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
        [self.delegate clickRecommendCellWithID:storeItemID];
    }
}

@end
