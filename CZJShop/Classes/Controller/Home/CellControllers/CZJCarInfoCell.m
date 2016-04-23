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
        label_type.textColor = CZJREDCOLOR;
        label_type.clipsToBounds = YES;
        label_type.layer.cornerRadius = 5;
        label_type.layer.borderWidth = 0.5;
        label_type.layer.borderColor = CZJREDCOLOR.CGColor;
        label_type.frame =  CGRectMake(10 , (frame.size.height - 20) / 2, 40, 20);
        
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        UILabel* label_title = [[UILabel alloc] init];
        label_title.textAlignment = NSTextAlignmentLeft;
        label_title.font = [UIFont systemFontOfSize:14.0f];;
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
    for (int i  = 0; i < _infocount; i++) {
        CGRect frame = CGRectMake(10, i * 39, _infoView.frame.size.width, _infoView.frame.size.height);
        CarInfoBarView* view = [[CarInfoBarView alloc]initWithFrame:frame AndData:_carInfoDatas[i]];
        [view setUserInteractionEnabled:YES];
        [view setTag:i + kStarTag];
        [view.titleButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        //信息条顺序往下添加
        [view.titleButton setTag:i];
        [_infoView addSubview:view];
    }
    UIView* lines = [[UIView alloc]initWithFrame:CGRectMake(0, (_infoView.frame.size.height - 20) / 2, 0.5, 20)];
    lines.backgroundColor = [UIColor lightGrayColor];
    [_infoView addSubview:lines];
    if (_infocount > 1)
    {
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(beginLoop:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.autoScrollTimer forMode:UITrackingRunLoopMode];
    }
}

- (void)buttonClick:(UIButton*)sender
{
    if (self.buttonClick) {
        self.buttonClick(_carInfoDatas[sender.tag]);
    }
}

- (void)beginLoop:(NSTimer*)timer
{
    for (UIView* subview in _infoView.subviews) {
        if ([subview isKindOfClass:[CarInfoBarView class]])
        {
            CarInfoBarView* view = (CarInfoBarView*)subview;
            __block CGRect frame = view.frame;
            __weak typeof(self) weak = self;
            [UIView animateWithDuration:1.0 animations:^{
                //向上移动
                [view setPosition:CGPointMake(frame.origin.x, frame.origin.y - weak.frame.size.height) atAnchorPoint:CGPointZero];
            } completion:^(BOOL finished) {
                //回到图形队列的最下面位置
                if (view.frame.origin.y == -weak.frame.size.height)
                {
                    [view setPosition:CGPointMake(frame.origin.x, (_infocount-1) * weak.frame.size.height) atAnchorPoint:CGPointZero];
                }
            }];
        }
    }
}

@end
