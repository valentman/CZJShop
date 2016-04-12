//
//  CZJMAAroundAnnotation.h
//  CZJShop
//
//  Created by Joe.Pen on 12/7/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "CZJStoreForm.h"
@interface CZJMAAroundAnnotation : MAPointAnnotation
@property(nonatomic, strong) CZJNearbyStoreForm *jzmaaroundM;
@property (nonatomic, copy) NSString *thrtitle;

@end
