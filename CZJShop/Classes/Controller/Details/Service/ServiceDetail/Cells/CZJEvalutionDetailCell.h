//
//  CZJEvalutionDetailCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/17/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJEvalutionDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *evalWriteHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *evalWriterName;
@property (weak, nonatomic) IBOutlet UILabel *evalWriteTime;
@property (weak, nonatomic) IBOutlet UILabel *replyContent;

@end
