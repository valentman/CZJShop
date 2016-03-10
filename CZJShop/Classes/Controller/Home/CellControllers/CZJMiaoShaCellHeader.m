//
//  CZJMiaoShaCellHeader.m
//  CZJShop
//
//  Created by Joe.Pen on 11/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJMiaoShaCellHeader.h"

@interface CZJMiaoShaCellHeader ()

@property (assign) BOOL timeStart;
@end

@implementation CZJMiaoShaCellHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
    _timeStart = YES;
}


- (void)initHeaderWithTimestamp:(NSString*)time
{
    self.isInit = YES;
    _timeStamp = [NSDate dateWithTimeIntervalSince1970:0];
}


- (void)timerFireMethod:(NSTimer *)theTimer
{
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDateComponents *endTime = [[NSDateComponents alloc] init];    //初始化目标时间...
    NSDate *today = [NSDate date];    //得到当前时间
    
    NSDate *date = [NSDate dateWithTimeInterval:60 sinceDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    static int year;
    static int month;
    static int day;
    static int hour;
    static int minute;
    static int second;
    if(_timeStart) {//从NSDate中取出年月日，时分秒，但是只能取一次
        year = [[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
        month = [[dateString substringWithRange:NSMakeRange(5, 2)] intValue];
        day = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
        hour = [[dateString substringWithRange:NSMakeRange(11, 2)] intValue];
        minute = [[dateString substringWithRange:NSMakeRange(14, 2)] intValue];
        second = [[dateString substringWithRange:NSMakeRange(17, 2)] intValue];
        _timeStart= NO;
    }
    
    [endTime setYear:year];
    [endTime setMonth:month];
    [endTime setDay:day];
    [endTime setHour:hour];
    [endTime setMinute:minute];
    [endTime setSecond:second];
    NSDate *todate = [cal dateFromComponents:endTime]; //把目标时间装载入date
    
    //用来得到具体的时差，是为了统一成北京时间
    unsigned int unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit| NSSecondCalendarUnit;
    NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:todate options:0];
    NSString *fen = [NSString stringWithFormat:@"%ld", [d minute]];
    if([d minute] < 10) {
        fen = [NSString stringWithFormat:@"0%ld",[d minute]];
    }
    NSString *miao = [NSString stringWithFormat:@"%ld", [d second]];
    if([d second] < 10) {
        miao = [NSString stringWithFormat:@"0%ld",[d second]];
    }
    
    if([d second] > 0) {
        
        //计时尚未结束，do_something
        
    } else if([d second] == 0) {
        
        //计时1分钟结束，do_something
        
    } else{
        [theTimer invalidate];
    }
    
}

@end
