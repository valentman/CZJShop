//
//  CZJMiaoShaCellHeader.m
//  CZJShop
//
//  Created by Joe.Pen on 11/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMiaoShaCellHeader.h"

@interface CZJMiaoShaCellHeader ()
{
    NSInteger _timestamp;
    NSTimer* timer;
}
@property (assign) BOOL timeStart;
@end

@implementation CZJMiaoShaCellHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    _timeStart = YES;
}


- (void)initHeaderWithTimestamp:(NSInteger)timeLeft
{
    self.isInit = YES;
    [self setTimestamp:timeLeft];
}

- (void)setTimestamp:(NSInteger)timestamp{
    _timestamp = timestamp;
    if (_timestamp != 0) {
        [self refreshLessTime];
        timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLessTime) userInfo:nil repeats:YES];
        // 如果不添加下面这条语句，在UITableView拖动的时候，会阻塞定时器的调用
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    }
}

- (void)refreshLessTime
{
    _timestamp--;
    CZJDateTime dateTime = [CZJUtils getLeftDatetime:_timestamp];
    NSString* hourStr = [NSString stringWithFormat:@"%ld", dateTime.hour];
    if (dateTime.hour < 10)
    {
        hourStr =[NSString stringWithFormat:@"0%ld", dateTime.hour];
    }
    self.hourLabel.text = hourStr;
    NSString* minutesStr = [NSString stringWithFormat:@"%ld", dateTime.minute];
    if (dateTime.minute < 10)
    {
        minutesStr = [NSString stringWithFormat:@"0%ld", dateTime.minute];
    }
    self.minutesLabel.text = minutesStr;
    NSString* secondStr = [NSString stringWithFormat:@"%ld", dateTime.second];
    if (dateTime.second < 10)
    {
        secondStr = [NSString stringWithFormat:@"0%ld", dateTime.second];
    }
    self.secondLabel.text = secondStr;
}


@end
