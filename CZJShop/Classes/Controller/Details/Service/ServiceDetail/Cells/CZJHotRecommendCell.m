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
    __block int cellHeight = 0;
    __block int cellWidth = 0;
    //得到第一个UIView
    for (CZJStoreServiceForm* form in hotRecommends)
    {
//        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CZJHotRecoCell" owner:self options:nil];
        CZJHotRecoCell* cell = [CZJUtils getXibViewByName:@"CZJHotRecoCell"];
        ;
        [cell.hotRecoImage sd_setImageWithURL:[NSURL URLWithString:form.itemImg] placeholderImage:nil];
        
        NSDictionary *dic = @{NSFontAttributeName: SYSTEMFONT(12)};
        CGSize hotSize = [form.itemName boundingRectWithSize:CGSizeMake(100, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
        cell.hotRecoName.text = form.itemName;
        
        DLog(@"%@,%f,%f",form.itemName,hotSize.width,hotSize.height);
        if (hotSize.height > 30)
        {
            hotSize.height = 30;
        }
        cell.hotRecoNameLayoutHeight.constant = hotSize.height;
        cell.hotRecoPrice.text = form.skillPrice;
        [hotRecoCells addObject:cell];
        cellHeight = cell.frame.size.height;
        cellWidth = cell.frame.size.width;
    }
    
    CGSize hotSize = CGSizeMake(PJ_SCREEN_WIDTH - 40, self.hotRecoPageScrollView.frame.size.height);
    CGRect hotRect = CGRectMake(20, 44, hotSize.width, hotSize.height);
    NSInteger numbers = hotRecommends.count / 6;
    UIView* pageView = [[LSPageScrollView alloc]initWithFrame:hotRect numberOfItem:numbers itemSize:hotSize complete:^(NSArray *items) {
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
                int childX = column * (cellWidth + 35);
                int childY = row * cellHeight;
                cell.frame = CGRectMake(childX , childY, hotRect.size.width, hotRect.size.height);
                [view addSubview:cell];
            }

        }
    }];
    [self.contentView addSubview:pageView];
}


@end
