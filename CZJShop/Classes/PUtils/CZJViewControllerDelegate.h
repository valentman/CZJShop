//
//  CommonViewControllerDelegate.h
//  CheZhiJian
//
//  Created by chelifang on 15/7/30.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CZJViewControllerDelegate <NSObject>

@optional
- (void)didCancel:(id)controller;
- (void)didDone:(id)controller;
- (void)didDone:(id)controller Info:(id)info;
- (void)didDone:(id)controller Text1:(NSString*)text1 Text2:(NSString*)text2 HeadImage:(UIImage*)image;
@end


@protocol CZJImageViewTouchDelegate <NSObject>

@optional
- (void)showActivityHtmlWithUrl:(NSString*)url;

- (void)showDetailInfoWithForm:(id)form;

@end
