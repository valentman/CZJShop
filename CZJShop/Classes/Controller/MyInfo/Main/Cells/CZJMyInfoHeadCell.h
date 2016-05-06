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
- (void)clickMyInfoHeadCell:(id)sender;
@end

@interface CZJMyInfoHeadCell : CZJTableViewCell
@property(weak, nonatomic)id<CZJMyInfoHeadCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *unLoginView;
@property (weak, nonatomic) IBOutlet UIView *haveLoginView;
@property (weak, nonatomic) IBOutlet CZJButton *messageBtn;

- (void)setUserPersonalInfo:(UserBaseForm*)userinfo;
@end
