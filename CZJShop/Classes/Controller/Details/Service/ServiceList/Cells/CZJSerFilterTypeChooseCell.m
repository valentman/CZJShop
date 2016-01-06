//
//  CZJSerFilterTypeChooseCell.m
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJSerFilterTypeChooseCell.h"
#import "HomeForm.h"

#define kCellSizeWith ((PJ_SCREEN_WIDTH - 50)/3.0f) //cell等分成三等份 按钮宽度
#define kCellLeftMargin (((PJ_SCREEN_WIDTH - 50) - 3*kButtonWidth) / 4)
#define kButtonHeight 38              //按钮高度
#define kButtonWidth 96              //按钮高度

#define kButtonTopMargin 15       //按钮距顶部margin
#define kButtonVertMargin 15      // 垂直margin

#define kButtonHoriMargin 10    //水平margin

@interface CZJSerFilterTypeChooseCell ()
{
    NSInteger cellType;
}
@end

@implementation CZJSerFilterTypeChooseCell

-(void)setButtonDatas:(NSArray *)buttonDatas WithType:(NSInteger)type{
    [super setButtonDatas:[buttonDatas mutableCopy]];
    DLog(@"%f",self.bounds.size.height);
    cellType = type;
    NSUInteger buttonCount = self.buttonDatas.count;
    //先初始化按钮
    for (int i = 0; i< buttonCount; i++)
    {
        UIButton *child = self.contentView.subviews[i];
        int divide = (buttonCount == 3) ? 3 : 3;
        // 列数
        int column = i%divide;
        // 行数
        int row = i/divide;
        // 很据列数和行数算出x、y
        int childX = column * (kButtonWidth + kCellLeftMargin);
        int childY = row * (kButtonHeight + kButtonVertMargin);
        child.frame = CGRectMake(childX + kCellLeftMargin, childY, kButtonWidth, kButtonHeight);
        child.hidden = NO;
        child.titleLabel.font = [UIFont systemFontOfSize:15];
        [child addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //根据传入的内容的不同，button的标题的获取方式不同
        switch (type) {
            case kCZJSerFilterTypeChooseCellTypeService:
            {
                NSString* name = [self.buttonDatas[i] valueForKey:@"name"];
                [child setTitle:name forState:UIControlStateNormal];
                NSString* typeID = [self.buttonDatas[i] valueForKey:@"typeId"];
                NSString* currentTypeId = [USER_DEFAULT valueForKey:kUserDefaultServiceTypeID];
                if ([typeID isEqualToString:currentTypeId])
                {
                    [self selectedBtnClick:child];
                }
            }
                break;
            case kCZJSerFilterTypeChooseCellTypeGoWhere:
            {
                NSString* name = self.buttonDatas[i];
                [child setTitle:name forState:UIControlStateNormal];
                if ([name isEqualToString:[USER_DEFAULT valueForKey:kUserDefaultServicePlace]])
                {
                    [self selectedBtnClick:child];
                }
            }
                break;
                
            case kCZJSerFilterTypeChooseCellTypeGoods:
            {
                NSString* name = self.buttonDatas[i];
                [child setTitle:name forState:UIControlStateNormal];
            }
                break;
                
            case kCZJSerfilterTypeChooseCellTypeDetail:
            {
                NSString* name = [self.buttonDatas[i] valueForKey:@"valueName"];
                [child setTitle:name forState:UIControlStateNormal];
                child.tag = [[self.buttonDatas[i] valueForKey:@"valueId"] integerValue];
            }
                break;
                
            default:
                break;
        }
    }
    DLog(@"%f",self.bounds.size.height);
}


- (void)setDefaultSelectBtn:(NSString*)selectdString
{
    for (int i = 0; i< self.buttonDatas.count; i++)
    {
        UIButton *child = self.contentView.subviews[i];
        if ([child.titleLabel.text isEqualToString:selectdString])
        {
            [self selectedBtnClick:child];
        }
    }
}

- (void)selectedBtnClick:(id)sender
{
    UIButton* _button = (UIButton*)sender;
    NSInteger tag = [_button tag];
    if (kCZJSerFilterTypeChooseCellTypeGoods == cellType)
    {
        if (_button.selected) {
            [_button setSelected:false];
            [_button setBackgroundColor:[UIColor whiteColor]];
            _button.layer.borderColor = RGB(180, 180, 180).CGColor;
            _button.layer.borderWidth = 0.5;
            _button.titleLabel.textColor = [UIColor grayColor];
            [_button setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        }
        else
        {
            [_button setSelected:true];
            [_button setBackgroundColor:RGB(251, 70, 78)];
            _button.layer.borderColor = RGB(251, 70, 78).CGColor;
            _button.titleLabel.textColor = [UIColor whiteColor];
            [_button setImage:[UIImage imageNamed:@"shaixuan_icon_gou"] forState:UIControlStateSelected];
            [_button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
    }
    else if (kCZJSerFilterTypeChooseCellTypeGoWhere == cellType ||
             kCZJSerFilterTypeChooseCellTypeService == cellType ||
             kCZJSerfilterTypeChooseCellTypeDetail == cellType)
    {
        for (UIButton* btn in self.contentView.subviews)
        {
            if (btn.tag == tag)
            {
                [btn setSelected:true];
                [btn setBackgroundColor:RGB(251, 70, 78)];
                btn.layer.borderColor = RGB(251, 70, 78).CGColor;
                btn.titleLabel.textColor = [UIColor whiteColor];
                [btn setImage:[UIImage imageNamed:@"shaixuan_icon_gou"] forState:UIControlStateSelected];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            }
            else
            {
                [btn setSelected:false];
                [btn setBackgroundColor:[UIColor whiteColor]];
                btn.layer.borderColor = RGB(180, 180, 180).CGColor;
                btn.layer.borderWidth = 0.5;
                btn.titleLabel.textColor = [UIColor grayColor];
                [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
            }
        }
    }

    NSString* typeID;
    switch (cellType) {
        case kCZJSerFilterTypeChooseCellTypeService:
        {
            ServiceForm* form = self.buttonDatas[tag];
            typeID = form.typeId;
            [USER_DEFAULT setValue:typeID forKey:kUserDefaultServiceTypeID];
        }
            break;
        case kCZJSerFilterTypeChooseCellTypeGoWhere:
        {
            typeID = self.buttonDatas[tag];
            [USER_DEFAULT setValue:typeID forKey:kUserDefaultServicePlace];
        }
            break;
        case kCZJSerFilterTypeChooseCellTypeGoods:
        {
            
        }
            break;
        case kCZJSerfilterTypeChooseCellTypeDetail:
        {
            if (self.buttonBlock)
            {
                self.buttonBlock(_button);
            }
        }
            break;
        default:
            break;
    }
}

@end
