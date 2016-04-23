//
//  CZJStoreDetailMenuCell.h
//  CZJShop
//
//  Created by Joe.Pen on 1/16/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJStoreDetailMenuCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic)NSMutableArray* titles;

- (void)updateCellTitleColor:(NSInteger)tapIndex;
@end
