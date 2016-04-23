//
//  CZJImageView.h
//  CZJShop
//
//  Created by Joe.Pen on 4/19/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJImageView : UIImageView
@property (strong, nonatomic) id czjData;
@property (assign, nonatomic) NSInteger subTag;
@property (assign, nonatomic) NSInteger secondTag;
@property (strong, nonatomic) UIButton* bigBtn;
@end
