//
//  CZJSpecialRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJSpecialRecommendCell.h"
#import "UIImageView+WebCache.h"
#import "HomeForm.h"

@implementation SpecialRecoCollectionViewCell

- (void)initSpecialRecoCollectionViewCellWithData:(NSString*)img
{
    UIImage* image = [UIImage imageNamed:@"home_btn_xiche"];
    SDWebImageCompletionBlock sdimgBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){};
    UIImageView* image_icon = [[UIImageView alloc] initWithImage:image];
    [image_icon sd_setImageWithURL:[NSURL URLWithString:img]
                  placeholderImage:[UIImage imageNamed:@"home_btn_xiche"]
                         completed:sdimgBlock];
    CGRect tmpRect = self.contentView.frame;
    image_icon.frame = tmpRect;
    [self.contentView addSubview:image_icon];
    
}

@end



@implementation CZJSpecialRecommendCell

- (void)awakeFromNib {
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

    // Configure the view for the selected state
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
}


#pragma mark- UICollectionDatasourceDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    DLog(@"%ld",_specialRecommendDatas.count);
    return _specialRecommendDatas.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SpecialRecoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:CZJSpecialRecoCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.layer.borderWidth = 5;
    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    cell.backgroundColor = [UIColor redColor];
    
    int index = indexPath.row;
    NSString* _imgString = ((SpecialRecommendForm*)_specialRecommendDatas[index]).img;
    [cell initSpecialRecoCollectionViewCellWithData:_imgString];
    return cell;
}
@end
