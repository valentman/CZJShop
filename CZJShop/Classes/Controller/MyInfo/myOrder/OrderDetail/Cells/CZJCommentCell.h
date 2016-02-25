//
//  CZJCommentCell.h
//  CZJShop
//
//  Created by Joe.Pen on 2/1/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJCommentCell : CZJTableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentHeight;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
