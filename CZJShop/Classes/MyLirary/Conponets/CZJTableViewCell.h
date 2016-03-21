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
@property (assign) BOOL isInit;
@property (assign) BOOL isSelected;
@property (copy, nonatomic) CZJButtonClickHandler buttonClick;
@end
