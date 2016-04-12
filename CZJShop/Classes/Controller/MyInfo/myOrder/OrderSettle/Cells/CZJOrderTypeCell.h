//
//  CZJOrderTypeCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/4/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJOrderForm.h"

@interface CZJOrderTypeCell : CZJTableViewCell

@property (strong, nonatomic)CZJOrderTypeForm* orderTypeForm;
@property (weak, nonatomic) IBOutlet UIImageView *orderTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *orderTypeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@end
