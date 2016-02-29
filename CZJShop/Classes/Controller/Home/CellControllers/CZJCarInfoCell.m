//
//  CZJCarInfoCell.m
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJCarInfoCell.h"

#define kStarTag 1000
@implementation CarInfoBarView
- (instancetype)initWithFrame:(CGRect)frame AndData:(CarInfoForm*)data
{
    if (self  = [super initWithFrame:frame])
    {
        //类型
        UILabel* label_type = [[UILabel alloc] init];
        label_type.textAlignment = NSTextAlignmentCenter;
        label_type.font = [UIFont systemFontOfSize:13.0f];;
        label_type.text = data.type;
        label_type.textColor = [UIColor redColor];
        label_type.clipsToBounds = YES;
        label_type.layer.cornerRadius = 5;
        label_type.layer.borderWidth = 0.5;
        label_type.layer.borderColor = [UIColor redColor].CGColor;
        label_type.frame =  CGRectMake(10 , (frame.size.height - 20) / 2, 40, 20);
        
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.frame = frame;
        
        UILabel* label_title = [[UILabel alloc] init];
        label_title.textAlignment = NSTextAlignmentLeft;
        label_title.font = [UIFont systemFontOfSize:16.0f];;
        label_title.text = data.title;
        label_title.frame = CGRectMake(60, 0, frame.size.width - 60, frame.size.height);
        
        [self addSubview:label_type];
        [self addSubview:label_title];
        [self addSubview:_titleButton];
        return self;
    }
    return nil;
}
@end


@interface CZJCarInfoCell ()
@property(assign) NSMutableArray* carInfoBarViews;
@property (assign)NSInteger infocount;
@end

@implementation CZJCarInfoCell

- (void)awakeFromNib {
    // Initialization code
    _carInfoBarViews = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initWithCarInfoDatas:(NSArray*)infoDatas andButtonClick:(CZJButtonClickHandler)buttonClick
{
    self.buttonClick = buttonClick;
    self.isInit = YES;
    _carInfoDatas = infoDatas;
    _infocount = _carInfoDatas.count;
    for (int i  = 0; i < _carInfoDatas.count; i++) {
        CGRect frame = CGRectMake(10, i * 39, _scrollInfoView.frame.size.width, _scrollInfoView.frame.size.height);
        CarInfoBarView* view = [[CarInfoBarView alloc]initWithFrame:frame AndData:_carInfoDatas[i]];
        [view setTag:i + kStarTag];
        [view.titleButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        //信息条顺序往下添加
        [view.titleButton setTag:i];
        [_scrollInfoView addSubview:view];
    }
    UIView* lines = [[UIView alloc]initWithFrame:CGRectMake(0, (_scrollInfoView.frame.size.height - 20) / 2, 0.5, 20)];
    lines.backgroundColor = [UIColor lightGrayColor];
    [_scrollInfoView addSubview:lines];
    
    _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(beginLoop:) userInfo:nil repeats:YES];
}

- (void)buttonClick:(UIButton*)sender
{
    if (self.buttonClick) {
        
        self.buttonClick(_carInfoDatas[sender.tag]);
    }
}

- (void)beginLoop:(NSTimer*)timer
{
    for (UIView* subview in _scrollInfoView.subviews) {
        if ([subview isKindOfClass:[CarInfoBarView class]])
        {
            CarInfoBarView* view = (CarInfoBarView*)subview;
            __block CGRect frame = view.frame;
            [UIView animateWithDuration:0.8
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 //向上移动
                                 frame = CGRectMake(frame.origin.x, frame.origin.y - self.frame.size.height, frame.size.width, frame.size.height);
                                 view.frame = frame;
                             }
                             completion:^(BOOL finished){
                                 //移出去得barview又返回最下面
                                 if (finished)
                                 {
                                     if (view.frame.origin.y == -self.frame.size.height)
                                     {
                                         view.frame = CGRectMake(view.frame.origin.x, (_infocount-1) * self.frame.size.height, frame.size.width, frame.size.height);
                                     }
                                 }
                                 
                             }];
        }
    }
}

@end
