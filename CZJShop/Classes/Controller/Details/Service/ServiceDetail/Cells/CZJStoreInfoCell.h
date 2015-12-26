//
//  CZJStoreInfoCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attentionNumber;
@property (weak, nonatomic) IBOutlet UILabel *goodsNumber;
@property (weak, nonatomic) IBOutlet UILabel *serviceNumber;

@property (weak, nonatomic) IBOutlet UIButton *contactServerButton;
@property (weak, nonatomic) IBOutlet UIButton *intoStoreButton;
@end
