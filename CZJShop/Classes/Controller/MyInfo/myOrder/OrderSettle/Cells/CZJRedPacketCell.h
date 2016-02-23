//
//  CZJRedPacketCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJRedPacketCellDelegate<NSObject>

- (void)clickToUseRedPacketCallBack:(id)sender andName:(NSString*)typeName;

@end

@interface CZJRedPacketCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *redPacketImg;
@property (weak, nonatomic) IBOutlet UILabel *redPacketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redBackWidth;
@property (weak, nonatomic) id<CZJRedPacketCellDelegate> delegate;

- (IBAction)selectAction:(id)sender;
@end
