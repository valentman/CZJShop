//
//  CZJGoodsListCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/18/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJGoodsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodPrice;
@property (weak, nonatomic) IBOutlet UILabel *goodRate;
@property (weak, nonatomic) IBOutlet UILabel *puchaseCount;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;

@end
