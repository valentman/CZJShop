//
//  CZJServiceCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeForm.h"

@interface ServiceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *serviceIcon;
@property (weak, nonatomic) UILabel *serviceName;

- (void)initServiceCollectionViewCellWithData:(ServiceForm*)obj;
@end


@interface CZJAFIndexedCollectionView : UICollectionView
@property (nonatomic, strong)NSIndexPath* indexPath;
@end

static NSString *CZJServiceCollectionViewCellIdentifier = @"CZJServiceCollectionViewCellIdentifier";



@protocol CZJServiceCellDelegate <NSObject>

- (void)showDetailInfoWithForm:(id)form;
@end

@interface CZJServiceCell : CZJTableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
{
//    id<CZJServiceCellDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet CZJAFIndexedCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *CZJAFCollectionLayout;
@property (assign) NSArray* services;
@property (nonatomic,weak) id<CZJServiceCellDelegate> delegate;


- (void)initServiceCellWithDatas:(NSArray *)datas;
@end
