//
//  CZJSpecialRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpecialRecoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *spcialRecoIcon;
- (instancetype)initWithFrame:(CGRect)frame;
@end

static NSString *CZJSpecialRecoCollectionViewCellIdentifier = @"CZJSpecialRecoCollectionViewCellIdentifier";
@interface CZJSpecialRecommendCell : CZJTableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSArray* _specialRecommendDatas;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate> delegate;

- (void)initSpecialRecommendWithDatas:(NSArray*)datas;
@end
