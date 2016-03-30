//
//  CZJHotRecommendCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPageScrollView.h"

@interface CZJHotRecommendCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet LSPageScrollView *hotRecoPageScrollView;


- (void)setHotRecommendDatas:(NSArray*)hotRecommends andButtonHandler:(CZJButtonClickHandler)buttonBlock;
@end
