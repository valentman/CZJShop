//
//  CZJSearchController.h
//  CZJShop
//
//  Created by Joe.Pen on 1/25/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SearchType)
{
    kSearchTypeHistory = 0,
    kSearchTypeServer
};
@interface CZJSearchController : CZJViewController
@property (nonatomic, weak) id <CZJViewControllerDelegate> delegate;
@property (nonatomic, weak) id parent;
@end
