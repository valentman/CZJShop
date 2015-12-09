//
//  CZJSpecialRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpecialRecoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *spcialRecoIcon;

- (void)initSpecialRecoCollectionViewCellWithData:(NSString*)img;
@end

static NSString *CZJSpecialRecoCollectionViewCellIdentifier = @"CZJSpecialRecoCollectionViewCellIdentifier";
@interface CZJSpecialRecommendCell : CZJTableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSArray* _specialRecommendDatas;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;

- (void)initSpecialRecommendWithDatas:(NSArray*)datas;
@end
