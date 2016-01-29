//
//  CZJMyInfoHeadCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseForm.h"

@protocol CZJMyInfoHeadCellDelegate <NSObject>
- (void)clickMyInfoHeadCell;
@end

@interface CZJMyInfoHeadCell : CZJTableViewCell
@property(weak, nonatomic)id<CZJMyInfoHeadCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *unLoginView;
@property (weak, nonatomic) IBOutlet UIView *haveLoginView;

- (void)setUserPersonalInfo:(UserBaseForm*)userinfo;
@end