//
//  CZJLimitBuyCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJLimitBuyCell.h"
#import "HomeForm.h"
#import "CZJMiaoShaCollectionCell.h"

@implementation CZJLimitBuyCell

- (void)awakeFromNib {
    // Initialization code
    _limitBuyDatas = [NSArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initLimitBuyWithDatas:(NSArray*)datas
{
    _limitBuyDatas = datas;
    self.isInit = YES;
    self.limitBuyCollectionView.dataSource = self;
    self.limitBuyCollectionView.delegate = self;
    self.limitBuyCollectionView.showsHorizontalScrollIndicator = NO;
    self.collectionViewLayout.itemSize = CGSizeMake(PJ_SCREEN_WIDTH/4, 135);
    
    UINib *nib=[UINib nibWithNibName:kCZJCollectionCellReuseIdMiaoSha bundle:nil];
    
    [self.limitBuyCollectionView registerNib: nib forCellWithReuseIdentifier:kCZJCollectionCellReuseIdMiaoSha];
    [self.limitBuyCollectionView reloadData];
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_limitBuyDatas.count==0) {
        return 0;
    }
    return _limitBuyDatas.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CZJMiaoShaCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCZJCollectionCellReuseIdMiaoSha forIndexPath:indexPath];
    
    LimitBuyForm * form;
    form = _limitBuyDatas[indexPath.row];
    
    NSString* rmb = @"￥";
    NSString* priceStr = [NSString stringWithFormat:@"￥%@",form.originalPrice];
    CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStr AndFontSize:14];
    cell.originPriceLayoutWidth.constant = priceSize.width + 5;
    [cell.originPriceLabel setAttributedText:[CZJUtils stringWithDeleteLine:priceStr]];
    cell.currentPriceLabel.text = [rmb stringByAppendingString:form.currentPrice];
    cell.iconImage.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:form.img] placeholderImage:DefaultPlaceHolderImage];
    return cell;
}
@end
