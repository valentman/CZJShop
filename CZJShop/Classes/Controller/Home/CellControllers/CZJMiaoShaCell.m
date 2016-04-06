//
//  CZJMiaoShaCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMiaoShaCell.h"
#import "CZJMiaoShaCollectionCell.h"


@interface CZJMiaoShaCell ()<UICollectionViewDataSource,UICollectionViewDelegate, UIBarPositioningDelegate>

@end

@implementation CZJMiaoShaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _miaoShaDatas = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initMiaoShaInfoWithData:(NSArray*)data
{
    _miaoShaDatas = data;
    self.isInit = YES;
    self.miaoShaCollectionView.dataSource = self;
    self.miaoShaCollectionView.delegate = self;
    self.miaoShaCollectionView.showsHorizontalScrollIndicator = NO;
    
    UINib *nib=[UINib nibWithNibName:kCZJCollectionCellReuseIdMiaoSha bundle:nil];
    [self.miaoShaCollectionView registerNib: nib forCellWithReuseIdentifier:kCZJCollectionCellReuseIdMiaoSha];
    [self.miaoShaCollectionView reloadData];
    
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionVie{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.miaoShaDatas.count==0) {
        return 0;
    }
    return self.miaoShaDatas.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(clickMiaoShaCellItem:)])
    {
        [self.delegate clickMiaoShaCellItem:nil];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CZJMiaoShaCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCZJCollectionCellReuseIdMiaoSha forIndexPath:indexPath];
    
    SecSkillsForm * form;
    form = _miaoShaDatas[indexPath.row];

    NSString* rmb = @"￥";
    NSString* priceStr = [NSString stringWithFormat:@"￥%@",form.originalPrice];
    CGSize priceSize = [CZJUtils calculateTitleSizeWithString:priceStr AndFontSize:14];
    cell.originPriceLayoutWidth.constant = priceSize.width + 5;
    NSAttributedString* priceDeleteStr = [CZJUtils stringWithDeleteLine:priceStr];
    [cell.originPriceLabel setAttributedText:priceDeleteStr];
    cell.currentPriceLabel.text = [rmb stringByAppendingString:form.currentPrice];
    cell.iconImage.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderImage];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(PJ_SCREEN_WIDTH/4, 135);
}

@end
