//
//  CZJPageControlView.h
//  CZJShop
//
//  Created by Joe.Pen on 12/16/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPagePicDetail 0
#define kPageNotice 1
#define kPageAfterSale 2
#define kPageAplicable 3

@interface CZJPageControlView : UIView

- (instancetype)initWithFrame:(CGRect)frame andPageIndex:(NSInteger)pageIndex;
- (void)setTitleArray:(NSArray*)titleArray andVCArray:(NSArray*)vcArray;
@end
