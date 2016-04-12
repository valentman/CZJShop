

//
//  CZJLeaveMessageView.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJLeaveMessageViewDelegate <NSObject>

- (void)clickConfirmMessage:(NSString*)message;

@end

@interface CZJLeaveMessageView : CZJViewController
@property (weak, nonatomic) id<CZJLeaveMessageViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *leaveMessageTextView;
@property (strong, nonatomic) NSString* leaveMesageStr;

@end
