//
//  CZJEvalutionDescCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZJEvalutionDescCell : CZJTableViewCell
{
    NSArray* stars;
}
@property (weak, nonatomic) IBOutlet UILabel *evalWriter;
@property (weak, nonatomic) IBOutlet UILabel *evalTime;
@property (weak, nonatomic) IBOutlet UILabel *evalContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *evalContentLayoutHeight;
@property (weak, nonatomic) IBOutlet UIImageView *starone;
@property (weak, nonatomic) IBOutlet UIImageView *starTwo;
@property (weak, nonatomic) IBOutlet UIImageView *starThr;
@property (weak, nonatomic) IBOutlet UIImageView *starFour;
@property (weak, nonatomic) IBOutlet UIImageView *starFive;
@property (weak, nonatomic) IBOutlet UIImageView *arrowNextImage;
@property (weak, nonatomic) IBOutlet UIView *picView;
- (void)setStar:(int)star;
@end
