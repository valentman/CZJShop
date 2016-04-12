//
//  CZJMyInfoHeadCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoHeadCell.h"

@interface CZJMyInfoHeadCell ()
@property (weak, nonatomic) IBOutlet CZJButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImg;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;

- (IBAction)messageAction:(id)sender;

@end

@implementation CZJMyInfoHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserPersonalInfo:(UserBaseForm*)userinfo
{
    self.userNameLabel.text = userinfo.chezhuName;
    self.userPhoneLabel.text = userinfo.mobile;
    [self.userHeadImg sd_setImageWithURL:[NSURL URLWithString:userinfo.chezhuHeadImg] placeholderImage:IMAGENAMED(@"my_icon_head")];
    self.userHeadImg.clipsToBounds = YES;
    self.userTypeLabel.text = userinfo.chezhuType;
    self.userTypeLabel.layer.cornerRadius = 9;
    self.userTypeLabel.layer.backgroundColor = RGBA(240, 240, 240,0.5).CGColor;
    [self.messageBtn setBadgeNum:-1];
}

- (IBAction)messageAction:(id)sender
{
    //消息中心
    [self.delegate clickMyInfoHeadCell:sender];
}

@end
