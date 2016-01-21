//
//  CZJMyInfoHeadCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoHeadCell.h"
#import "UIImageView+WebCache.h"

@interface CZJMyInfoHeadCell ()
@property (weak, nonatomic) IBOutlet UIView *unLoginView;
@property (weak, nonatomic) IBOutlet UIView *haveLoginView;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
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
    self.unLoginView.hidden = YES;
    self.haveLoginView.hidden = NO;
    self.userNameLabel.text = userinfo.chezhuName;
    self.userPhoneLabel.text = userinfo.mobile;
    [self.userHeadImg sd_setImageWithURL:[NSURL URLWithString:userinfo.chezhuHeadImg] placeholderImage:IMAGENAMED(@"my_icon_head")];
    self.userHeadImg.layer.cornerRadius = 38;
    self.userHeadImg.clipsToBounds = YES;
    self.userTypeLabel.text = userinfo.chezhuType;
    self.userTypeLabel.layer.cornerRadius = 9;
    self.userTypeLabel.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.userTypeLabel.layer.borderWidth = 1;
    self.userTypeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (IBAction)messageAction:(id)sender
{
    //消息中心
    [self.delegate clickMyInfoHeadCell];
}
@end
