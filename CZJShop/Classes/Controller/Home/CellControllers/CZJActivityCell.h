//
//  CZJActivityCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/19/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZADScrollerView.h"

@class ActivityForm;

@interface CZJActivityCell : CZJTableViewCell<FZADScrollerViewDelegate>{
    NSMutableArray* _imageArray;
}

@property (strong, nonatomic) FZADScrollerView *adScrollerView;
@property (strong, nonatomic) NSMutableArray* activeties;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate> delegate;

- (void)someMethodNeedUse:(NSIndexPath *)indexPath DataModel:(NSMutableArray*)array;
@end
