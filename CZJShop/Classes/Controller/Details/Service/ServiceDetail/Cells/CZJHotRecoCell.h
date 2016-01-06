//
//  CZJHotRecoCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJHotRecoCell : UIView
@property (weak, nonatomic) IBOutlet UIImageView *hotRecoImage;
@property (weak, nonatomic) IBOutlet UILabel *hotRecoName;
@property (weak, nonatomic) IBOutlet UILabel *hotRecoPrice;
@property (weak, nonatomic) IBOutlet UIButton *cellBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotRecoNameLayoutHeight;

@end
