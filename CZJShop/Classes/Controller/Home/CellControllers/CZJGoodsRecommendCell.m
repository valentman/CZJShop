//
//  CZJGoodsRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJGoodsRecommendCell.h"
#import "UIImageView+WebCache.h"
#import "CZJGoodsRecoCollectionCell.h"
#import "HomeForm.h"

@implementation CZJGoodsRecommendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initGoodsRecommendWithDatas:(NSArray*)datas
{
    _goodsRecommendDatas = datas;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    CGRect rect = self.frame;
    self.collectionViewLayout.itemSize = CGSizeMake((PJ_SCREEN_WIDTH-29) / 2, rect.size.height - 9);
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionViewLayout.minimumLineSpacing = 9;
    UIEdgeInsets sectionset = UIEdgeInsetsMake(0, 10, 9, 10);
    self.collectionViewLayout.sectionInset = sectionset;
    
    UINib *nib=[UINib nibWithNibName:kCZJCollectionCellReuseIdGoodReco bundle:nil];
    [self.collectionView registerNib: nib forCellWithReuseIdentifier:kCZJCollectionCellReuseIdGoodReco];
    [self.collectionView reloadData];
}


#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionVie{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_goodsRecommendDatas.count==0) {
        return 0;
    }
    return _goodsRecommendDatas.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CZJGoodsRecoCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCZJCollectionCellReuseIdGoodReco forIndexPath:indexPath];
    DLog(@"%@",cell);
    GoodsRecommendForm * form;
    form = _goodsRecommendDatas[indexPath.row];
    
    NSString* rmb = @"￥";
    cell.productName.text = form.name;
    cell.productPrice.text = [rmb stringByAppendingString:form.currentPrice];
    cell.iconImageView.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:form.img] placeholderImage:nil];
    return cell;
}
@end
