//
//  CZJStoreDetailHeadCell.h
//  CZJShop
//
//  Created by PJoe on 16-1-12.
//  Copyright (c) 2016年 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePlayerView.h"

@protocol CZJStoreDetailHeadCellDelegate <NSObject>
- (void)clickAttentionButton:(id)sender;

@end

@interface CZJStoreDetailHeadCell : CZJTableViewCell<ImagePlayerViewDelegate>
{
    NSMutableArray* _imageArray;
}
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeAddrLabel;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UILabel *attentionCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImgLayoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLayoutWidth;

@property (weak, nonatomic) IBOutlet ImagePlayerView *picDetailView;
@property (weak, nonatomic) NSMutableArray* activeties;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate> delegate;
@property (weak, nonatomic) id<CZJStoreDetailHeadCellDelegate> attentionDelegate;
- (void)someMethodNeedUse:(NSIndexPath *)indexPath DataModel:(NSMutableArray*)array;
- (IBAction)attentionStoreAction:(id)sender;
@end
