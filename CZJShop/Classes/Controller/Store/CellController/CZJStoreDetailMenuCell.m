//
//  CZJStoreDetailMenuCell.m
//  CZJShop
//
//  Created by Joe.Pen on 1/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJStoreDetailMenuCell.h"

@implementation CZJStoreDetailMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titles = [NSMutableArray array];
    //主要是下拉菜单的菜单名及旁边的黑小三角以及中间分隔线
    NSArray* titleAry = @[@"全部",@"销量",@"最新",@"价格"];
    for (int i = 0; i < 4; i++)
    {   //菜单名
        CATextLayer *title = [CATextLayer new];
        CGPoint position = CGPointMake( (i * 2 + 1) * PJ_SCREEN_WIDTH / ( 4 * 2) , self.myView.frame.size.height / 2);
        title = [CZJUtils creatTextLayerWithNSString:titleAry[i] withColor:[UIColor darkGrayColor] andPosition:position andNumOfMenu:4];
        [self.myView.layer addSublayer:title];
        [self.titles addObject:title];
    }
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMenu:)];
    [self addGestureRecognizer:tapGesture];
    
    [self updateCellTitleColor:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tapMenu:(UITapGestureRecognizer *)paramSender
{
    // 得到tapIndex(点击的菜单项)
    CGPoint touchPoint = [paramSender locationInView:self];
    NSInteger tapIndex = touchPoint.x / (PJ_SCREEN_WIDTH / 4);
    
    if (self.buttonClick)
    {
        self.buttonClick([NSString stringWithFormat:@"%ld",tapIndex]);
        [self updateCellTitleColor:tapIndex];
    }
}

- (void)updateCellTitleColor:(NSInteger)tapIndex
{
    if (tapIndex == 0)
        return;
    
    for ( int i = 0; i < self.titles.count; i++)
    {
        CATextLayer *title = (CATextLayer*)self.titles[i];
        title.foregroundColor = [UIColor darkGrayColor].CGColor;
        if (i == tapIndex)
        {
            title.foregroundColor = CZJREDCOLOR.CGColor;
        }
    }
}


@end
