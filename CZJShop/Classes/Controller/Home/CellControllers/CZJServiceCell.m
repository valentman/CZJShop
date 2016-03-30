 //
//  CZJServiceCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceCell.h"

@implementation ServiceCollectionViewCell

- (void)initServiceCollectionViewCellWithData:(ServiceForm*)obj
{
    //图片
    SDWebImageCompletionBlock sdimgBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){};
    UIImageView* image_icon = [[UIImageView alloc] init];
    [image_icon sd_setImageWithURL:[NSURL URLWithString:obj.img]
                  placeholderImage:PNGIMAGE( @"home_btn_xiche")
                         completed:sdimgBlock];
    
    //标题
    UILabel* label_name = [[UILabel alloc] init];
    label_name.textAlignment = NSTextAlignmentCenter;
    label_name.font = [UIFont systemFontOfSize:12.0f];;
    label_name.text = obj.name;
    
    //布局
    CGRect tmpRect = self.contentView.frame;
    image_icon.frame = CGRectMake((tmpRect.size.width - 40) / 2 , 0, 40, 40);
    label_name.frame = CGRectMake(0 , 40 + 7, tmpRect.size.width, 15);
    [self setHighlighted:NO];
    [self.contentView addSubview:image_icon];
    [self.contentView addSubview:label_name];
    
}
@end

@implementation CZJAFIndexedCollectionView

@end

@implementation CZJServiceCell

- (void)awakeFromNib {
    // Initialization code
    self.CZJAFCollectionLayout.itemSize = CGSizeMake(PJ_SCREEN_WIDTH/5, 75);
    [self.collectionView registerClass:[ServiceCollectionViewCell class]
            forCellWithReuseIdentifier:CZJServiceCollectionViewCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    _services = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initServiceCellWithDatas:(NSArray *)datas{
    self.isInit = YES;
    _services = [datas mutableCopy];
    [self.collectionView reloadData];
}


#pragma mark---imageCollectionView--------------------------
#pragma mark- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPat
{
    DLog(@"serviceCell item:%ld", indexPat.row);
    if ([_delegate respondsToSelector:@selector(showDetailInfoWithForm:)])
    {
        [_delegate showDetailInfoWithForm:_services[indexPat.row]];
    }
}


#pragma mark- UICollectionDatasourceDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _services.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ServiceCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:CZJServiceCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell initServiceCollectionViewCellWithData:_services[indexPath.row]];
    return cell;
}

@end
