//
//  CZJLimitBuyCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJLimitBuyCell : CZJTableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSArray* _limitBuyDatas;
}
@property (weak, nonatomic) IBOutlet UICollectionView *limitBuyCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;

- (void)initLimitBuyWithDatas:(NSArray*)datas;
@end
