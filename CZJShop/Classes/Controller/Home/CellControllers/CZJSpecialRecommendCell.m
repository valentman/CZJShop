//
//  CZJSpecialRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJSpecialRecommendCell.h"
#import "HomeForm.h"

@implementation SpecialRecoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        _spcialRecoIcon = [[UIImageView alloc] init];
        CGRect tmpRect = self.contentView.frame;
        _spcialRecoIcon.frame = tmpRect;
        [self.contentView addSubview:_spcialRecoIcon];
        return self;
    }
    return nil;
}
@end


@implementation CZJSpecialRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.collectionViewLayout.itemSize = CGSizeMake((PJ_SCREEN_WIDTH - 1) / 3, 98);
    self.collectionViewLayout.minimumInteritemSpacing = 0.5;
    self.collectionViewLayout.minimumLineSpacing = 0.5;
    UIEdgeInsets conteninset = UIEdgeInsetsMake(0.5, 0, 0, 0);
    self.collectionViewLayout.sectionInset = conteninset;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView registerClass:[SpecialRecoCollectionViewCell class]
            forCellWithReuseIdentifier:CZJSpecialRecoCollectionViewCellIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initSpecialRecommendWithDatas:(NSArray*)datas
{
    self.isInit = YES;
    _specialRecommendDatas = datas;
    [self.collectionView reloadData];
}

#pragma mark---imageCollectionView--------------------------
#pragma mark- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPat
{
    [self.delegate showActivityHtmlWithUrl:((SpecialRecommendForm*)_specialRecommendDatas[indexPat.item]).url];
}


#pragma mark- UICollectionDatasourceDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _specialRecommendDatas.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SpecialRecoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:CZJSpecialRecoCollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    NSString* _imgString = ((SpecialRecommendForm*)_specialRecommendDatas[index]).img;
    [cell.spcialRecoIcon sd_setImageWithURL:[NSURL URLWithString:_imgString] placeholderImage:DefaultPlaceHolderImage];
    return cell;
}
@end
