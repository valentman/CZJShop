//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NIDropDown;
@protocol NIDropDownDelegate
- (void) niDropDownDelegateMethod:(NSString*)btnStr;
@end 

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) id <NIDropDownDelegate> delegate;

-(void)hideDropDown:(id)b;
- (id)showDropDown:(id)target Frame:(CGRect)rect WithObjects:(NSArray *)arr;
@end
