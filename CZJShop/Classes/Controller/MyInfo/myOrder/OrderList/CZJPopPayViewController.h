//
//  CZJPopPayViewController.h
//  CZJShop
//
//  Created by Joe.Pen on 2/23/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZJPopPayViewDelegate <NSObject>

- (void)payViewToPay:(id)sender;

@end

@interface CZJPopPayViewController : UIViewController
@property (nonatomic, copy) MGBasicBlock basicBlock;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)float contentHeight;
@property (nonatomic, assign)float orderMoney;
@property (nonatomic, weak)id<CZJPopPayViewDelegate> delegate;

- (void)setCancleBarItemHandle:(CZJGeneralBlock)basicBlock;

@end
