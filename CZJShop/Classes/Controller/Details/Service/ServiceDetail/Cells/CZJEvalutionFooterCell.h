//
//  CZJEvalutionFooterCell.h
//  CZJShop
//
//  Created by Joe.Pen on 12/15/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLookAllEvalView 5001
#define kEvalDetailView 5002

@interface CZJEvalutionFooterCell : CZJTableViewCell<CZJImageViewTouchDelegate>
@property (weak, nonatomic) IBOutlet UIView *allEvalView;
@property (weak, nonatomic) IBOutlet UIView *evalDetailView;
@property (weak, nonatomic) IBOutlet UIButton *evalutionReplyBtn;
@property (weak, nonatomic) IBOutlet UIButton *addEvaluateBtn;

@property (weak, nonatomic) IBOutlet UILabel *seeAllEvalution;

@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceTime;
@property (weak, nonatomic) id<CZJImageViewTouchDelegate>delegate;
@property (strong, nonatomic)CZJEvaluateForm* form;

- (IBAction)replyEvalutionAction:(id)sender;
- (void)setVisibleView:(NSInteger)type;
@end
