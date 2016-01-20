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
    //主要是下拉菜单的菜单名及旁边的黑小三角以及中间分隔线
    NSArray* titleAry = @[@"全部",@"销量",@"最新",@"价格"];
    for (int i = 0; i < 4; i++)
    {   //菜单名
        CATextLayer *title = [CATextLayer new];
        CGPoint position = CGPointMake( (i * 2 + 1) * PJ_SCREEN_WIDTH / ( 4 * 2) , self.frame.size.height / 2);
        title = [CZJUtils creatTextLayerWithNSString:titleAry[i] withColor:[UIColor darkGrayColor] andPosition:position andNumOfMenu:4];
        [self.layer addSublayer:title];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
