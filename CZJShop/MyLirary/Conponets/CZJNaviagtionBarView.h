//
//  CZJNaviagtionBarView.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJNaviagtionBarViewDelegate <NSObject>

- (void)clickEventCallBack:(nullable id)sender;

@end

@interface CZJNaviagtionBarView : UIView

@property(nullable,nonatomic,weak) id<CZJNaviagtionBarViewDelegate> delegate;
- (nullable instancetype)initWithFrame:(CGRect)bounds AndTag:(NSInteger)tag;

@end
