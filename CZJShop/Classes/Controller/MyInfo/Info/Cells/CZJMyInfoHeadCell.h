//
//  CZJMyInfoHeadCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJMyInfoHeadCellDelegate <NSObject>
- (void)clickMyInfoHeadCell;
@end

@interface CZJMyInfoHeadCell : CZJTableViewCell
@property(weak, nonatomic)id<CZJMyInfoHeadCellDelegate> delegate;

@end
