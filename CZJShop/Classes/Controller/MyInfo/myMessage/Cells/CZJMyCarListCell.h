//
//  CZJMyCarListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CZJMyCarListCellDelegate <NSObject>

- (void)deleteMyCarActionCallBack:(id)sender;
- (void)setDefaultAcitonCallBack:(id)sender;

@end

@interface CZJMyCarListCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *brandImg;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) id<CZJMyCarListCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *carNumberPlate;

- (IBAction)deleteMyCarAction:(id)sender;
- (IBAction)setDefaultAction:(id)sender;
@end
