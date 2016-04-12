//
//  CZJMiaoShaCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMiaoShaCellDelegate <NSObject>

- (void)clickMiaoShaCellItem:(id)sender;

@end

@interface CZJMiaoShaCell : CZJTableViewCell
{
}
@property (weak, nonatomic) IBOutlet UICollectionView *miaoShaCollectionView;
@property (assign)NSArray* miaoShaDatas;
@property (weak, nonatomic) id<CZJMiaoShaCellDelegate> delegate;

- (void)initMiaoShaInfoWithData:(NSArray*)data;
@end
