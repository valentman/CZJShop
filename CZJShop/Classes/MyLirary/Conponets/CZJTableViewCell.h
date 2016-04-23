//
//  CZJTableView.h
//  CZJShop
//
//  Created by Joe.Pen on 11/30/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CZJButtonClickHandler)(id data);

@interface CZJTableViewCell : UITableViewCell
@property (assign, nonatomic) BOOL isInit;
@property (assign, nonatomic) BOOL isSelected;

/**
 *  可以和系统自带分割线交替使用，当需要缩进的是选择系统的，设置缩进值即可，当需要全部铺满时，用此替代。
 */
@property (strong, nonatomic)UIView* separatorView;

/**
 *  回调Block
 */
@property (copy, nonatomic) CZJButtonClickHandler buttonClick;

- (void)setSeparatorViewHidden:(BOOL)_hidden;
@end
