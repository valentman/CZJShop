//
//  CZJEvalutionDescCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJEvalutionDescCell : UITableViewCell
{
    NSArray* stars;
}
@property (weak, nonatomic) IBOutlet UILabel *evalWriter;
@property (weak, nonatomic) IBOutlet UILabel *evalTime;
@property (weak, nonatomic) IBOutlet UILabel *evalContent;
@property (weak, nonatomic) IBOutlet UIImageView *addtionnalImage;
@property (weak, nonatomic) IBOutlet UIImageView *starone;
@property (weak, nonatomic) IBOutlet UIImageView *starTwo;
@property (weak, nonatomic) IBOutlet UIImageView *starThr;
@property (weak, nonatomic) IBOutlet UIImageView *starFour;
@property (weak, nonatomic) IBOutlet UIImageView *starFive;
- (void)setStar:(int)star;
@end
