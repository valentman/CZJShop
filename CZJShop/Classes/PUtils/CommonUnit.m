//
//  CommonUnit.m
//  CheZhiJian
//
//  Created by chelifang on 15/9/5.
//  Copyright (c) 2015年 chelifang. All rights reserved.
//

#import "CommonUnit.h"
#import "FDAlertView.h"
#import "AppDelegate.h"

@interface CommonUnit ()<FDAlertViewDelegate>{
    int _type;
}

@end


@implementation CommonUnit

-(id)init{
    if ([super init]) {
        _type = 0;
        return self;
    }
    return nil;
}
+ (CommonUnit *)shareCommonUnit{
    static CommonUnit *sharedCommonUnit = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCommonUnit = [[self alloc] init];
    });
    return sharedCommonUnit;
}

- (void)showAlertViewWithContent:(NSString*)content{
    _type = 0;
    FDAlertView *alert = [[FDAlertView alloc] initWithTitle:@"提示"
                                                       icon:nil
                                                    message:content
                                                   delegate:self
                                               buttonTitles:@"确定",nil];
    [alert show];
}

- (void)showExitAlertViewWithContent{
    _type = 1;
    FDAlertView *alert = [[FDAlertView alloc] initWithTitle:@"提示"
                                                       icon:nil
                                                    message:@"您需去应用商店更新版本，否则将无法正常使用"
                                                   delegate:self
                                               buttonTitles:@"取消",@"更新",nil];
    [alert show];
//    sleep(10000);
}

- (void)alertView:(FDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_type) {
        if (buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/id1035567397"]];
        }else{
            [self exitApplication];
        }
    }
}

- (void)exitApplication {
    
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    UIWindow *window = app.window;
//    
//    [UIView animateWithDuration:1.0f animations:^{
//        window.alpha = 0;
//        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//    } completion:^(BOOL finished) {
//        exit(0);
//    }];
    
}
@end
