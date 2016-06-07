//
//  CZJGeneralSubCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJGeneralSubCell.h"
#import "CZJButtonView.h"

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
//    buttons = [NSMutableArray array];
//    titles = [NSMutableArray array];
//    [buttons addObject:_button1];
//    [buttons addObject:_button2];
//    [buttons addObject:_button3];
//    [buttons addObject:_button4];
//    [buttons addObject:_button5];
//    [titles addObject:_title1];
//    [titles addObject:_title2];
//    [titles addObject:_title3];
//    [titles addObject:_title4];
//    [titles addObject:_title5];
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
        CZJButtonView* btnView = [CZJUtils getXibViewByName:@"CZJButtonView"];
        CGRect btnViewRect = [CZJUtils viewFrameFromDynamic:CZJMarginMake(20, 0) size:CGSizeMake(60, 60) index:i divide:(int)items.count subWidth:0];
        btnView.frame = btnViewRect;
        [self addSubview:btnView];
        [btnView.viewBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btnView.viewBtn.tag = i + 1;
        btnView.viewLabel.text = [dict valueForKey:@"title"];
        if (type == kCZJGeneralSubCellTypeWallet)
        {
            [btnView.viewBtn setImage:nil forState:UIControlStateNormal];
            [btnView.viewBtn setTitle:[dict valueForKey:@"buttonTitle"] forState:UIControlStateNormal];
            [btnView.viewBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            btnView.viewBtn.titleLabel.font = SYSTEMFONT(12);
        }
        if (type == kCZJGeneralSubCellTypeOrder)
        {
            [btnView.viewBtn setBadgeNum:0];
            [btnView.viewBtn setImage:IMAGENAMED([dict valueForKey:@"buttonImage"]) forState:UIControlStateNormal];
            [btnView.viewBtn setBadgeNum:[[dict valueForKey:@"budge"] integerValue]];
            [btnView.viewBtn setBadgeLabelPosition:CGPointMake(btnView.viewBtn.frame.size.width*0.75, btnView.viewBtn.frame.size.height*0.1)];
        }
    }
}

- (IBAction)btnAction:(id)sender
{
    [self.delegate clickSubCellButton:sender andType:cellType];
}
@end
