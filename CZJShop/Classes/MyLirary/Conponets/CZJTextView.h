//
//  CZJTextView.h
//  CZJShop
//
//  Created by Joe.Pen on 2/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CZJTextView : UITextView
@property(nonatomic,copy) NSString *myPlaceholder;  //文字

@property(nonatomic,strong) UIColor *myPlaceholderColor; //文字颜色
@end
