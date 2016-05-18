//
//  CZJChatViewButtomView.h
//  CZJShop
//
//  Created by Joe.Pen on 5/10/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseChatToolbar.h"

@protocol CZJChatViewButtomViewDelegate <NSObject>

- (void)takePicAction:(id)sender;
- (void)photoAction:(id)sender;
- (void)emotionAction:(id)sender;
- (void)myOrderAction:(id)sender;
- (void)scanRecordAction:(id)sender;

@end

@interface CZJChatViewButtomView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *scanRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *myOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *emotionBtn;
@property (weak, nonatomic) IBOutlet UIButton *picBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *emotionImg;


@property (weak, nonatomic) id<CZJChatViewButtomViewDelegate>delegate;

- (IBAction)takePicAction:(id)sender;
- (IBAction)photoAction:(id)sender;
- (IBAction)scanRecordAction:(id)sender;
- (IBAction)myOrderAction:(id)sender;
- (IBAction)emotionAction:(id)sender;

@end
