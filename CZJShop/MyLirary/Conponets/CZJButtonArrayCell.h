//
//  CZJButtonArrayCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/11/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CZJButtonArrayCell;

@protocol CZJButtonArrayCellDelegate <NSObject>
-(void)cityTableViewCell:(CZJButtonArrayCell *)cityTableViewCell didClickLocationBtnTitle:(NSString *)title;
-(void)cityTableViewCell:(CZJButtonArrayCell *)cityTableViewCell didClickBtnTitle:(NSString *)title andId:(NSString *)typeID;

@end

@interface CZJButtonArrayCell : UITableViewCell
{
    NSMutableArray *_buttonDatas;
}
@property (nonatomic, strong) NSMutableArray *buttonDatas;
@property (nonatomic, weak) id<CZJButtonArrayCellDelegate>delegate;

@end
