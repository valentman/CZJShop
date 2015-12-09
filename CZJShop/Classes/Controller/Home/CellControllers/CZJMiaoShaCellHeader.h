//
//  CZJMiaoShaCellHeader.h
//  CZJShop
//
//  Created by Joe.Pen on 11/21/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJMiaoShaCellHeader : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *miaoShaChangCi;
@property (weak, nonatomic) IBOutlet UIView *hourView;
@property (weak, nonatomic) IBOutlet UIView *minutesView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (assign) NSDate* timeStamp;

- (void)initHeaderWithTimestamp:(NSString*)time;
@end
