//
//  CZJDeletableImageView.h
//  CZJShop
//
//  Created by Joe.Pen on 2/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJDeletableImageView : UIView
@property (strong, nonatomic)NSString* imgName;
@property (strong, nonatomic)UIButton* deleteButton;

- (id)initWithFrame:(CGRect)frame andImageName:(NSString*)imageName;
@end
