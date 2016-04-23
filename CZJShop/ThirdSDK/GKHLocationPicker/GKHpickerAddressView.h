//
//  VTSelectionPickerView.h
//  huiyang
//  一个地理位置选择器
//  Created by Mac on 14-2-21.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

typedef void (^passStrValueBlock) (UIViewController * ctrl,NSString * addressName);

@interface GKHpickerAddressView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIView* _backGroundView;
}
@property (strong,nonatomic) UIPickerView * pickerView;
@property (strong,nonatomic) passStrValueBlock  valueBlock;
@property (strong,nonatomic) UIViewController * ctrl;
/* 选择城市名
 @param
 *mobileNum：传入controller
 @return
 *block：addressName    选择的名字
 */
+ (GKHpickerAddressView *)shareInstancePickerAddressByctrl:(UIViewController *)ctrl block:(passStrValueBlock)block;
@end
