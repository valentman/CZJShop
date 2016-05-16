//
//  CZJGoodsChatCell.m
//  CZJShop
//
//  Created by Joe.Pen on 5/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJGoodsChatCell.h"
#import "CZJScanRecordMessageCell.h"

@implementation CZJGoodsChatCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self)
    {
        CZJScanRecordMessageCell* goodsCell = [CZJUtils getXibViewByName:@"CZJScanRecordMessageCell"];
        goodsCell.frame = self.bubbleView.frame;
//        [self.bubbleView addSubview:goodsCell];
    }
    return self;
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendGoods":@"EaseMessageCellRecvGoods";
}

@end
