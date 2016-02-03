//
//  CZJOrderDetailCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/26/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJOrderDetailCell.h"
@interface CZJOrderDetailCell()
@property (weak, nonatomic) IBOutlet UIButton *buttonOne;
@property (weak, nonatomic) IBOutlet UIButton *buttonTwo;
@property (weak, nonatomic) IBOutlet UIButton *buttonThree;
@property (weak, nonatomic) IBOutlet UIButton *buttonFour;
@property (weak, nonatomic) IBOutlet UIImageView *stageImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stagelabelcenterLeading;


@end

@implementation CZJOrderDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrderStateLayout:(NSInteger)state type:(NSInteger)type
{
    self.buttonOne.hidden = YES;
    self.buttonTwo.hidden = YES;
    self.buttonThree.hidden = YES;
    self.buttonFour.hidden = YES;
    switch (state) {
        case 0:
            self.buttonOne.hidden = NO;
            [self.stageImg setImage:IMAGENAMED(@"order_icon_pay")];
            break;
            
        case 1:
            self.buttonTwo.hidden = NO;
            if (0 == type)
            {
                [self.stageImg setImage:IMAGENAMED(@"order_icon_shouhuo")];
            }
            else
            {
                [self.stageImg setImage:IMAGENAMED(@"order_icon_shigong")];
            }
            break;
            
        case 2:
            self.buttonThree.hidden = NO;
            [self.stageImg setImage:IMAGENAMED(@"order_icon_recommend")];
            break;
            
        case 3:
            self.buttonFour.hidden = NO;
            [self.stageImg setImage:IMAGENAMED(@"order_icon_gou2")];
            break;
            
        default:
            break;
    }
}
@end
