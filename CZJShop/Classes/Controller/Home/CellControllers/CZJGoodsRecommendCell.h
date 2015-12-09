//
//  CZJGoodsRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CZJGoodsRecommendCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray* _goodsRecommendDatas;
}

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)initGoodsRecommendWithDatas:(NSArray*)datas;
@end
