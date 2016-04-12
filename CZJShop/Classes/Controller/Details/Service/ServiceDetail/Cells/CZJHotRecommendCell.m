//
//  CZJHotRecommendCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJHotRecommendCell.h"
#import "CZJHotRecoCell.h"
#import "CZJStoreForm.h"

@implementation CZJHotRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHotRecommendDatas:(NSArray*)hotRecommends andButtonHandler:(CZJButtonClickHandler)buttonBlock
{
    self.isInit = YES;
    NSMutableArray* hotRecoCells = [NSMutableArray array];
    __block int cellHeight = (iPhone5 || iPhone4) ? 160 : 160;
    __block int cellWidth = (iPhone5 || iPhone4) ? 90 : 100;
    //初始化HotRecoCell
    for (CZJStoreServiceForm* form in hotRecommends)
    {
        CZJHotRecoCell* cell = [CZJUtils getXibViewByName:@"CZJHotRecoCell"];
        cell.hotRecoData = form;
        cell.hotBtnClick = buttonBlock;
        //品牌图片
        [cell.hotRecoImage sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:DefaultPlaceHolderSquare];
        //品牌名称
        cell.hotRecoName.text = form.itemName;
        DLog(@"%@",form.itemName);
        CGSize hotSize = [CZJUtils calculateStringSizeWithString:form.itemName Font:SYSTEMFONT(12) Width:cellWidth - 5];
        cell.hotRecoNameLayoutHeight.constant = hotSize.height > 30 ? 30 : 15;
        //品牌价格
        cell.hotRecoPrice.text = [NSString stringWithFormat:@"￥%@",form.currentPrice];
        
        [hotRecoCells addObject:cell];
    }
    //布局到PageScrollView上
    CGSize hotSize = CGSizeMake(PJ_SCREEN_WIDTH, self.hotRecoPageScrollView.frame.size.height);
    CGRect hotRect = CGRectMake(0, 44, hotSize.width, hotSize.height);
    int horiMiddleMargin = (PJ_SCREEN_WIDTH - 40 - 3 * cellWidth) / 2;
    int vertiMiddleMargin = 10;
    NSInteger numbers = hotRecommends.count / 6;
    UIView* pageView = [[LSPageScrollView alloc]initWithFrame:hotRect numberOfItem:numbers itemSize:hotSize complete:^(NSArray *items)
    {
        for (int i = 0; i < items.count; i++)
        {
            UIView* view = items[i];
            for (int j  = i*6; j < (i+1)*6; j++)
            {
                CZJHotRecoCell* cell = hotRecoCells[j];
                int x = j - i*6;
                int divide = 3;
                // 列数
                int column = x%divide;
                // 行数
                int row = x/divide;
                DLog(@"row:%d, column:%d", row, column);
                // 很据列数和行数算出x、y
                int childX = column * (cellWidth + horiMiddleMargin);
                int childY = row * (cellHeight + vertiMiddleMargin);
                cell.frame = CGRectMake(childX + 20, childY, cellWidth, cellHeight);
                [view addSubview:cell];
            }
        }
    }];
    [self.contentView addSubview:pageView];
}


@end
