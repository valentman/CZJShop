//
//  CZJCustomAnnotationView.h
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CZJCustomCallOutView.h"
#import "CZJMAAroundAnnotation.h"

@interface CZJCustomAnnotationView : MAAnnotationView

@property(nonatomic, strong) CZJCustomCallOutView *calloutView;

/*!
 @brief 关联的annotation
 */
@property (nonatomic, strong) CZJMAAroundAnnotation *jzAnnotation;

@end
