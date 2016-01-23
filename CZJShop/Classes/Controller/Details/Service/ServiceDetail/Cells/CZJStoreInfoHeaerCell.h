//
//  CZJStoreInfoHeaerCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJStoreInfoHeaerCellDelegate <NSObject>

- (void)clickAttentionStore:(id)sender;

@end

@interface CZJStoreInfoHeaerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *storeImage;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *storeAddr;
@property (weak, nonatomic) IBOutlet UIButton *attentionStore;
@property (weak, nonatomic) id<CZJStoreInfoHeaerCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLayoutWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeAddrLayoutWidth;

- (IBAction)attentionStoreAction:(id)sender;

@end
