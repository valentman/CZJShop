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
#import "UIImageView+WebCache.h"

@implementation CZJHotRecommendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHotRecommendDatas:(NSArray*)hotRecommends
{
    self.isInit = YES;
    NSMutableArray* hotRecoCells = [NSMutableArray array];
    int cellHeight;
    int cellWidth;
    for (CZJStoreServiceForm* form in hotRecommends)
    {
        CZJHotRecoCell* cell = [[CZJHotRecoCell alloc]init];
        [cell.hotRecoImage sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:nil];
        cell.hotRecoName.text = form.itemName;
        cell.hotRecoPrice.text = form.skillPrice;
        [hotRecoCells addObject:cell];
        cellHeight = cell.frame.size.height;
        cellWidth = cell.frame.size.width;
    }
    
    
    
    CGRect hotRect = self.hotRecoPageScrollView.frame;
    NSInteger numbers = hotRecommends.count / 6;
    self.hotRecoPageScrollView = [[LSPageScrollView alloc]initWithFrame:hotRect numberOfItem:numbers itemSize:hotRect.size complete:^(NSArray *items) {
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
                int childX = column * cellWidth;
                int childY = row * cellHeight;
                cell.frame = CGRectMake(childX , childY, hotRect.size.width, hotRect.size.height);
                [view addSubview:cell];
            }

        }
    }];
}


@end
