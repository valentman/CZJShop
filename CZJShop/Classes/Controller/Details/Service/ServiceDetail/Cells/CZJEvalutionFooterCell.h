//
//  CZJEvalutionFooterCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZJDetailForm.h"

#define kLookAllEvalView 5001
#define kEvalDetailView 5002

@interface CZJEvalutionFooterCell : UITableViewCell<CZJImageViewTouchDelegate>
@property (weak, nonatomic) IBOutlet UIView *allEvalView;
@property (weak, nonatomic) IBOutlet UIView *evalDetailView;
@property (weak, nonatomic) IBOutlet UIButton *evalutionReplyBtn;
@property (weak, nonatomic) IBOutlet UILabel *seeAllEvalution;

@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceTime;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate>delegate;
@property (strong, nonatomic)CZJEvalutionsForm* form;

- (IBAction)replyEvalutionAction:(id)sender;
- (void)setVisibleView:(NSInteger)type;
@end
