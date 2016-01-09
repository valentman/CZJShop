//
//  CZJCarInfoCell.h
//  CZJShop
//
//  Created by Joe.Pen on 11/20/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeForm.h"

@interface CarInfoBarView : UIView
- (instancetype)initWithFrame:(CGRect)frame AndData:(CarInfoForm*)data;
@end

@interface CZJCarInfoCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *carInfoWordImg;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollInfoView;
@property (assign) NSArray* carInfoDatas;
@property (nonatomic, strong) NSTimer *autoScrollTimer;



- (void)initWithCarInfoDatas:(NSArray*)infoDatas;
@end
