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
        if (!timer) {
            timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLessTime) userInfo:nil repeats:YES];
            // 如果不添加下面这条语句，在UITableView拖动的时候，会阻塞定时器的调用
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
        }
    }
}

- (void)refreshLessTime
{
    _timestamp--;
    CZJDateTime* dateTime = [CZJUtils getLeftDatetime:_timestamp];
    self.hourLabel.text = dateTime.hour;
    self.minutesLabel.text = dateTime.minute;
    self.secondLabel.text = dateTime.second;
    if (0 == _timestamp)
    {
        [timer invalidate];
        timer = nil;
        if (self.buttonClick)
        {
            self.buttonClick(nil);
        }
    }
}
@end
