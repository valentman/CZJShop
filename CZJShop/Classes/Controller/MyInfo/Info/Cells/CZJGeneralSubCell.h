//
//  CZJGeneralSubCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCZJGeneralSubCellTypeOrder 6001
#define kCZJGeneralSubCellTypeWallet 6002

@protocol CZJGeneralSubCellDelegate <NSObject>

- (void)clickSubCellButton:(UIButton*)button;

@end


@interface CZJGeneralSubCell : CZJTableViewCell
@property (weak, nonatomic)id<CZJGeneralSubCellDelegate> delegate;

- (void)setGeneralSubCell:(NSArray*)titles andType:(int)type;
@end
