//
//  CZJGeneralSubCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJGeneralSubCell.h"

@interface CZJGeneralSubCell ()
{
    NSMutableArray* buttons;
    NSMutableArray* titles;
    int cellType;
}
@property (weak, nonatomic) IBOutlet CZJButton *button1;
@property (weak, nonatomic) IBOutlet CZJButton *button2;
@property (weak, nonatomic) IBOutlet CZJButton *button3;
@property (weak, nonatomic) IBOutlet CZJButton *button4;
@property (weak, nonatomic) IBOutlet CZJButton *button5;

@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *title4;
@property (weak, nonatomic) IBOutlet UILabel *title5;

- (IBAction)btnAction:(id)sender;

@end

@implementation CZJGeneralSubCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    buttons = [NSMutableArray array];
    titles = [NSMutableArray array];
    [buttons addObject:_button1];
    [buttons addObject:_button2];
    [buttons addObject:_button3];
    [buttons addObject:_button4];
    [buttons addObject:_button5];
    [titles addObject:_title1];
    [titles addObject:_title2];
    [titles addObject:_title3];
    [titles addObject:_title4];
    [titles addObject:_title5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setGeneralSubCell:(NSArray*)items andType:(int)type
{
    cellType = type;
    for (int i =0; i < items.count; i++)
    {
        NSDictionary* dict = (NSDictionary*)items[i];
        CZJButton* _btn = buttons[i];
        UILabel* _label = titles[i];
        _label.text = [dict valueForKey:@"title"];
        if (type == kCZJGeneralSubCellTypeWallet)
        {
            [_btn setImage:nil forState:UIControlStateNormal];
            [_btn setTitle:[dict valueForKey:@"buttonTitle"] forState:UIControlStateNormal];
            [_btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            _btn.titleLabel.font = SYSTEMFONT(12);
        }
        if (type == kCZJGeneralSubCellTypeOrder)
        {
            [_btn setImage:IMAGENAMED([dict valueForKey:@"buttonImage"]) forState:UIControlStateNormal];
            [_btn setBadgeNum:[[dict valueForKey:@"budge"] integerValue]];
            [_btn setBadgeLabelPosition:CGPointMake(_btn.frame.size.width*0.75, _btn.frame.size.height*0.05)];
        }
    }

}

- (IBAction)btnAction:(id)sender
{
    [self.delegate clickSubCellButton:sender andType:cellType];
}
@end
