 //
//  CZJServiceCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJServiceCell.h"

@implementation ServiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        _serviceName = [[UILabel alloc] init];
        _serviceName.textAlignment = NSTextAlignmentCenter;
        _serviceName.font = [UIFont systemFontOfSize:12.0f];;
        _serviceName.frame = CGRectMake(0 , 40 + 7, frame.size.width, 15);
        [self.contentView addSubview:_serviceName];
        
        _serviceIcon = [[UIImageView alloc] init];
        _serviceIcon.frame = CGRectMake((frame.size.width - 40) / 2 , 0, 40, 40);
        [self.contentView addSubview:_serviceIcon];
        
        return self;
    }
    return nil;
}

- (void)initServiceCollectionViewCellWithData:(ServiceForm*)obj
{
    [_serviceIcon sd_setImageWithURL:[NSURL URLWithString:obj.img]
                  placeholderImage:DefaultPlaceHolderCircle
                         completed:nil];
    _serviceName.text = obj.name;
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
    self.collectionView.scrollEnabled = NO;
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
